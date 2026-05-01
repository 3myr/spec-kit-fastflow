# Changelog

## 1.0.0 (2026-04-10)

- Initial release
- Add `/speckit.tinyspec` command for generating single-file lightweight specs
- Add `/speckit.tinyspec.implement` command for implementing directly from tinyspec files
- Add `/speckit.tinyspec.classify` command for routing tasks to tinyspec or full SDD
- Optional `before_specify` hook for auto-classifying task complexity
- Addresses community request in issue #1174 (22+ reactions)

## 2.0.0 (2026-05-01)

- Forked from tinyspec and rewritten for speed, simplicity, and MVP-ready stability
- Renamed to FastFlow, focusing on single-file, evolutive specs for feature increments
- All commands and logic refactored for small, fast, and stable MVP applications
- Added `/speckit.fastflow`, `/speckit.fastflow.implement`, and `/speckit.fastflow.classify` commands
- FastFlow file format: combines intent, scope, architecture, plan, and tasks in one document