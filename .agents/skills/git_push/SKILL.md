---
name: git_push
description: Git workflow automation - groups changed files by feature, generates detailed conventional commit messages, handles conflicts, and pushes to GitHub. Use when user says "commit", "push", "subir cambios", "git push", "guardar cambios", or "push to github".
---

# Git Feature Push

Automates git workflow: detects changes, groups by feature path, generates detailed conventional commit messages based on inspectable diffs/context, handles upstream conflicts, and pushes to GitHub.

## Trigger Phrases

Activate this skill when the user says any of:

- "commit", "commit y push", "push", "push to github"
- "subir cambios", "subir a github", "subir los cambios", "guardar"
- "git feature", "git push", "guardar cambios", "hacer commit"

## Step-by-Step Workflow

### Step 1: Pre-flight

1. `git branch --show-current` — get current branch
2. `git status --porcelain` — detect all changed files
3. `git log --oneline -5` — recent commits for style reference

If no changes (empty porcelain), tell user "No hay cambios para commitear" and stop.

### Step 2: Conflict check & pull

1. `git fetch origin`
2. `git status` — check if behind remote
3. If behind: `git pull --rebase origin <branch>`
   - Success → continue
   - Conflict → `git rebase --abort`, tell user "Hay conflictos con el remoto. Resuelve manualmente con git pull." and stop.

### Step 3: Analyze & group changes

Parse each line of `git status --porcelain`:

**Porcelain format:** `XY <filepath>`

- `X` = index status (staging area)
- `Y` = working tree status
- `??` = untracked file

**A) Feature group** by path (dynamic extraction):

| Path Pattern                       | Scope / Group Name                    |
| ---------------------------------- | ------------------------------------- |
| `lib/features/<feature_name>/...`  | `<feature_name>` (e.g. `chat_import`) |
| `lib/core/...`                     | `core`                                |
| `lib/shared/...`                   | `shared`                              |
| `lib/main.dart` or `lib/app.dart`  | `app`                                 |
| `.database/`                       | `database`                            |
| `assets/...`                       | `assets`                              |
| Everything else                    | `config`                              |

**B) Commit type** by change content & intent:

| Condition                                | Type             |
| ---------------------------------------- | ---------------- |
| New feature, screen, or capability       | `feat`           |
| Bug fix or correction                    | `fix`            |
| Code restructuring, cleanup, or removal  | `refactor`       |
| Performance improvements                 | `perf`           |
| `pubspec.yaml` / config updates          | `chore`          |
| `.sql` or database migration files       | `fix` / `feat`   |
| Test files (`*_test.dart`)               | `test`           |
| Markdown docs (`.md`)                    | `docs`           |
| Default                                  | `chore`          |

**C) Detailed Message Generation (CRITICAL)**

Before generating the message for a group, **inspect the actual diff** using `git diff <files>` or review the session context to understand **what** changed and **why**.

#### Rules for Commit Messages:
1. **NEVER use generic descriptions** like `update <group> module`, `fix files`, `changes`, or `work in progress`.
2. **Be specific and descriptive**: Specify exact components, widgets, methods, fields, or UI elements modified.
3. **Structure**: `<type>(<scope>): <detailed action & context>`
4. **Multi-line Body (Optional for complex changes)**: If a group has multiple distinct changes, add a second `-m` argument detailing key points.

#### Patterns & Examples:

- **UI / Dropzone Update:**
  `feat(chat_import): add whatsapp export instructions without media in upload dropzone`
- **Domain & UI Refactoring:**
  `refactor(chat_dashboard): remove audio count statistics and replace audio king card with top writer`
- **Fixing Logic / Parsers:**
  `fix(chat_import): correct regex parsing for whatsapp exported timestamps`
- **Adding Tests:**
  `test(chat_import): add unit test coverage for zip extractor edge cases`
- **Dependencies / Chore:**
  `chore(deps): update receive_sharing_intent and flutter_riverpod dependencies`

#### Complex Change Example with Body:
```bash
git commit -m "refactor(chat_dashboard): remove audio statistics and update social roles UI" -m "- Remove audioCount and totalAudios from MessageAnalysis model
- Replace Audio vs Writer card with dedicated Writer card in social roles section
- Update Chat Wrapped dialog to feature El Mas Popular instead of Rey del Audio"
```

### Step 4: Stage & commit by group

Process groups in logical dependency order (e.g. `core`, `shared`, feature groups in alphabetical order, `app`, `config`).

For each group:

1. `git add <file1> <file2> ...`
2. Run `git diff --staged` or inspect diff if detail needs verification.
3. `git commit -m "<type>(<scope>): <detailed_subject>" [-m "<optional_body_bullet_points>"]`

### Step 5: Push

1. `git push origin <branch>`
2. If push fails with non-fast-forward:
   - `git pull --rebase origin <branch>`
   - Success → `git push origin <branch>`
   - Conflict → `git rebase --abort`, tell user "Push rechazado. Resuelve los conflictos manualmente."

### Step 6: Report

Show concise summary:

```
✅ N commits pushed to origin/<branch>

  1. <type>(<scope>): <detailed_description>
  2. <type>(<scope>): <detailed_description>
  ...
```

## Rules

- NEVER use `git push --force` or `git push -f`
- NEVER commit `.env`, secrets, or API keys
- ALWAYS use conventional commit format (`<type>(<scope>): <message>`)
- ALWAYS create **detailed, specific** commit messages explaining the change (NO generic "update module" text)
- ALWAYS show the push summary
- If user provides a custom message, use their detail while maintaining conventional commit format
- Skip empty groups (no files to add)
- One commit per feature group, never mix features in the same commit
