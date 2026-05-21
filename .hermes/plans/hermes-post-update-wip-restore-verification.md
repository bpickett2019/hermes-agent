# Verification — Hermes v0.14.0 post-update WIP restore

## Goal
Restore Bailey-local Hermes WIP after `hermes update`, resolve update conflicts, and verify the restored changes remain compatible with Hermes Agent v0.14.0.

## Restored local changes
- `tools/delegate_tool.py` — MiniMax `/anthropic` endpoint credential resolution uses `anthropic_messages` mode.
- `tests/tools/test_delegate.py` — regression coverage for MiniMax `/anthropic` endpoint and stabilized heartbeat stale-threshold test.
- `tools/discord_tool.py` — Discord admin support for `create_category` and `create_channel` with parent/topic args and 403 hints.
- `tests/tools/test_discord_tool.py` — regression coverage for category/channel creation and error handling.
- `website/sidebars.ts` — adds Knowledge & RAG docs sidebar grouping for Obsidian, Qmd, and Chroma docs.
- `.hermes/plans/add-obsidian-rag-sidebar*.md` — original plan/verification for docs sidebar slice.

## Conflict resolution
`git stash apply stash@{0}` produced one conflict in `tests/tools/test_delegate.py` between upstream `/anthropic` custom endpoint tests and local MiniMax `/anthropic` test. Resolution kept both upstream tests and the MiniMax regression test.

## Checks

### Python syntax + targeted tests
Command:
```bash
python -m py_compile tools/delegate_tool.py tools/discord_tool.py && \
python -m pytest tests/tools/test_delegate.py tests/tools/test_discord_tool.py -q -o 'addopts='
```
Result: PASS — `235 passed`.

### Referenced docs exist
Command:
```bash
test -f website/docs/user-guide/skills/bundled/note-taking/note-taking-obsidian.md && \
  test -f website/docs/user-guide/skills/optional/research/research-qmd.md && \
  test -f website/docs/user-guide/skills/optional/mlops/mlops-chroma.md && \
  echo 'all referenced docs exist'
```
Result: PASS — all referenced docs exist.

### Docusaurus production build
Command:
```bash
cd website && npm run build
```
Result: PASS — Docusaurus generated static files for `en`, `zh-Hans`, and `ko`.

Notes: Build emitted existing broken-link/broken-anchor warnings, especially localized `/zh-Hans/docs/...` and `/ko/docs/...` paths plus the existing `rl-training.md` feature link. Build exited `0`; none of the new Knowledge & RAG sidebar doc IDs were missing.

### Hermes runtime status
Command:
```bash
hermes --version
hermes status --all
```
Result: PASS — Hermes Agent v0.14.0 reports `Up to date`; gateway is running; Discord configured; OpenAI Codex auth logged in; MiniMax configured.

## Remaining risk
- The original safety stash remains available as `stash@{0}: pre-hermes-update-20260521T010334Z` until explicitly dropped.
- Website build warnings are pre-existing docs/localization debt and were not introduced by this WIP restore.
