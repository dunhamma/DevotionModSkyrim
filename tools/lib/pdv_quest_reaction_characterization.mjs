function rowToken(row) {
  return [row.deityId, row.valence, row.intensity, row.magnitude, row.tag].join("|");
}

function surfaceSummary(rows) {
  const positive = rows.filter((row) => row.appliedAmount > 0);
  const negative = rows.filter((row) => row.appliedAmount < 0);
  if (!positive.length && !negative.length) {
    return {
      positiveRows: 0,
      negativeRows: 0,
      surfaceKind: "none",
      lead: "none",
      prismaToasts: 0,
      bookOfDaysEntries: 0,
    };
  }
  if (!negative.length) {
    return {
      positiveRows: positive.length,
      negativeRows: 0,
      surfaceKind: "positive",
      lead: "positive",
      prismaToasts: 1,
      bookOfDaysEntries: 1,
    };
  }
  if (!positive.length) {
    return {
      positiveRows: 0,
      negativeRows: negative.length,
      surfaceKind: "negative",
      lead: "negative",
      prismaToasts: 1,
      bookOfDaysEntries: 1,
    };
  }
  const strongestPositive = Math.max(...positive.map((row) => row.appliedAmount));
  const strongestNegative = Math.min(...negative.map((row) => row.appliedAmount));
  return {
    positiveRows: positive.length,
    negativeRows: negative.length,
    surfaceKind: "mixed",
    lead: strongestPositive >= Math.abs(strongestNegative) ? "positive" : "negative",
    prismaToasts: 1,
    bookOfDaysEntries: 1,
  };
}

export function runQuestReactionScenario(fixture) {
  const state = {
    sequence: fixture.initialState?.pendingCount ?? 0,
    queue: Array.from(
      { length: fixture.initialState?.pendingCount ?? 0 },
      (_, index) => ({
        jobId: `v3qr_${index + 1}`,
        key: `${fixture.initialState.pendingKeyPrefix}${index + 1}`,
        logicalEventId: "seed",
        rows: [],
        cursor: 0,
        started: false,
      }),
    ),
    recent: new Map(),
  };
  const observations = {
    submissions: [],
    applied: [],
    startedJobIds: [],
    finalizations: [],
    slices: [],
    rejections: [],
    cleanedJobIds: [],
    resumeCount: 0,
    queueDepth: 0,
  };

  function submit(step) {
    if (state.queue.some((job) => job.key === step.key)) {
      observations.submissions.push({ key: step.key, status: "coalesced-queued" });
      return;
    }
    if (state.queue.length >= fixture.config.maxPending) {
      observations.submissions.push({ key: step.key, status: "overflow" });
      observations.rejections.push({ key: step.key, reason: "overflow" });
      return;
    }
    const priorGameDay = state.recent.get(step.key);
    const elapsed = step.gameDay - priorGameDay;
    if (
      priorGameDay !== undefined &&
      elapsed >= 0 &&
      elapsed < fixture.config.duplicateWindowDays
    ) {
      observations.submissions.push({ key: step.key, status: "coalesced-recent" });
      return;
    }
    state.recent.set(step.key, step.gameDay);
    state.sequence += 1;
    const jobId = `v3qr_${state.sequence}`;
    state.queue.push({
      jobId,
      key: step.key,
      logicalEventId: step.logicalEventId,
      rows: [...step.rows, ...step.metaRows],
      cursor: 0,
      started: false,
    });
    const submission = { key: step.key, status: "accepted", jobId };
    if (Number.isInteger(step.sourceRowCount)) {
      submission.sourceRows = step.sourceRowCount;
      submission.runnableRows = step.rows.length + step.metaRows.length;
      submission.skippedRows = step.sourceRowCount - step.rows.length;
      submission.metaRows = step.metaRows.length;
    }
    observations.submissions.push(submission);
  }

  function tick() {
    const job = state.queue[0];
    if (!job) return;
    if (job.cursor < 0 || job.cursor > job.rows.length) {
      observations.slices.push({
        jobId: job.jobId,
        applied: [],
        finalized: false,
        rejected: "corrupt-snapshot",
      });
      observations.rejections.push({
        key: job.key,
        jobId: job.jobId,
        reason: "corrupt-snapshot",
      });
      state.queue.shift();
      observations.cleanedJobIds.push(job.jobId);
      return;
    }
    if (!job.started) {
      job.started = true;
      observations.startedJobIds.push(job.jobId);
    }
    const applied = [];
    while (
      applied.length < fixture.config.workItemsPerTick &&
      job.cursor < job.rows.length
    ) {
      const token = rowToken(job.rows[job.cursor]);
      observations.applied.push(token);
      applied.push(token);
      job.cursor += 1;
    }
    const finalized = job.cursor >= job.rows.length;
    observations.slices.push({ jobId: job.jobId, applied, finalized });
    if (!finalized) return;

    const appliedRows = job.rows.length;
    observations.finalizations.push({
      key: job.key,
      logicalEventId: job.logicalEventId,
      appliedRows,
      ...surfaceSummary(job.rows),
    });
    state.queue.shift();
    observations.cleanedJobIds.push(job.jobId);
  }

  for (const step of fixture.steps) {
    if (step.type === "submit-quest-stage") submit(step);
    else if (step.type === "tick") tick();
    else if (step.type === "corrupt-head") {
      if (!state.queue.length) throw new Error("Cannot corrupt an empty queue");
      state.queue[0].cursor = step.cursor;
    }
    else if (step.type === "save-load") {
      state.queue = JSON.parse(JSON.stringify(state.queue));
      state.recent = new Map([...state.recent.entries()]);
      if (state.queue.length) observations.resumeCount += 1;
    }
    else if (step.type === "drain") {
      while (state.queue.length) tick();
    } else {
      throw new Error(`Unknown characterization step: ${step.type}`);
    }
  }
  observations.queueDepth = state.queue.length;
  return observations;
}
