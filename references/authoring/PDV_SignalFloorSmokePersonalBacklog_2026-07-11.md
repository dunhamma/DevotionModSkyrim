# PDV Signal-Floor Smoke Personal Backlog - 2026-07-11

Status: personal bug-report follow-up list, not a 1.0 blocker.

This file records owner-waived checks from the 1.0 signal-floor co-test closeout. These are not claimed as proven. Use them only if a tester or player reports matching behavior.

## Waived Organic Checks

| Area | What was proven | Waived follow-up | Revisit if |
|---|---|---|---|
| Paarthurnax kill | Controlled MCM Card 11 routed Shor, Tsun, Kyne, Stendarr, Stuhn, and Mara reactions in Papyrus.0.log. | Organic kill on a reachable listed-god race. | A report says killing Paarthurnax normally gives no toast, no Book of Days entry, wrong gods, or wrong polarity. |
| Paarthurnax kill repeat | Controlled route fired once during smoke. | Repeat after save/load remains blocked. | A report says the Paarthurnax kill reaction can be farmed or re-fired after reload. |
| Khajiit Paarthurnax kill | Matrix/runtime contract preserves the Khajiit Alkosh branch. | Khajiit organic kill display was not run. | A Khajiit report says Alkosh does not respond, responds with wrong tone, or suppresses the expected general kill consequences. |
| Paarthurnax spare | Controlled MCM Card 12 routed Stuhn, Stendarr, Mara, and Kyne reactions in Papyrus.0.log. | Organic MQ305 stage-200 spare proof with Paarthurnax alive. | A report says sparing Paarthurnax gives no recognition or wrong gods. |
| Paarthurnax spare latch | Controlled spare route fired on the test path. | Spare stays silent after the kill latch has already fired. | A report says both kill and spare consequences can stack in one save. |
| Likes/dislikes v15 daily cap | v15 load marker and MCM LD v15 debug route proved events 303 and 366. Organic cow event 303 and MCM 366 were observed separately. | Strict cow-repeat daily-cap proof was waived because cow testing caused bounty friction. | A report says animal-kill or vampire-feed dislike rows repeat beyond intended caps. |

## Proof Boundary

Controlled MCM route proof is valid for route/debug smoke. It does not prove organic quest-stage or adversary behavior. The 2026-07-11 closeout explicitly accepts these waived items as personal backlog rather than 1.0 blockers.
