# Dialogue v1 Fixture

This fixture is a generic CK dialogue proof scaffold. It is not tied to a
Player Devotion phase.

The fixture covers the reusable shape needed for future dialogue work:

- CK-owned dialogue branch creation (`DLBR`)
- CK-owned dialogue topic creation (`DIAL`)
- CK-owned Topic Info creation (`INFO`), including unnamed INFO readback by
  topic, speaker, response line, and conditions
- SEQ freshness as a separate artifact proof gate

The fixture is allowed to plan CKPE commands only in discovery mode with
`allowUnprovenCk`. It must not promote `DIAL` or `INFO` support until the native
CKPE handlers create and save the records and a proof ledger contains passing
command evidence plus live readback.
