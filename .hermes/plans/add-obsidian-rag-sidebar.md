# Add Obsidian and RAG Database to docs sidebar

## Goal
Make the left docs navigation expose Obsidian and the local RAG/knowledge database docs so users do not have to find them only through the generated skills catalog.

## Scope
- Update `website/sidebars.ts` only.
- Add a compact Knowledge & RAG grouping under Features.
- Link existing generated docs rather than editing auto-generated skill pages.

## Proposed Entries
- Obsidian → `user-guide/skills/bundled/note-taking/note-taking-obsidian`
- RAG Database (Qmd) → `user-guide/skills/optional/research/research-qmd`
- Vector Database (Chroma) → `user-guide/skills/optional/mlops/mlops-chroma`

Including Chroma covers the vector-database/RAG-database interpretation, while Qmd covers the local personal RAG database interpretation.

## Verification
- Type-check/build docs sidebar via website build if dependencies are available.
- At minimum, verify referenced doc files exist and TypeScript syntax remains valid.
