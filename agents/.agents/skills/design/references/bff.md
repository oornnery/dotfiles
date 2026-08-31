# BFF

Add a BFF only when a client needs:

- aggregation across services;
- client-specific reshaping;
- secure token/session mediation;
- latency reduction via server-side fan-out/cache;
- stable frontend contract over changing backends.

Do not duplicate business authority in BFF. Define timeout, partial failure, caching,
and ownership.
