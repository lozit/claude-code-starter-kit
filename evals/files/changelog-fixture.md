<!-- fixture for evals/evals.json case 4 — a CHANGELOG mid-cycle, with a section name that repeats -->
# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Changed
- **The importer accepts a trailing separator** — a CSV whose last column ends with `;` no longer loses its final field.

### Fixed
- **Timezone drift on nightly rollups** — the aggregator used the server's local zone instead of UTC, so a row filed at 23:40 landed on the wrong day.

## [2.4.0] - 2026-08-02

### Added
- **Bulk export** — the whole ledger as one archive, streamed rather than buffered.

### Changed
- **Session cookies are rotated on privilege change**, not only at login.

### Fixed
- **A stale cache served deleted attachments** for up to five minutes after removal.

## [2.3.1] - 2026-07-11

### Changed
- **The retry budget is per-request, not per-connection.**
