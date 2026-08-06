---
name: git_push
description: Git workflow automation - groups changed files by feature, generates conventional commit messages, handles conflicts, and pushes to GitHub. Use when user says "commit", "push", "subir cambios", "git push", "guardar cambios", or "push to github".
---

# Git Feature Push

Automates git workflow: detects changes, groups by feature path, generates conventional commit messages, handles upstream conflicts, and pushes to GitHub.

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

**A) Feature group** by path:

| Path                              | Group        |
| --------------------------------- | ------------ |
| `lib/features/auth/`              | `auth`       |
| `lib/features/student/`           | `student`    |
| `lib/features/instructor/`        | `instructor` |
| `lib/features/course/`            | `course`     |
| `lib/features/cash_box/`          | `cash_box`   |
| `lib/features/home/`              | `home`       |
| `lib/features/user/`              | `user`       |
| `lib/core/`                       | `core`       |
| `.database/`                      | `database`   |
| `lib/main.dart` or `lib/app.dart` | `app`        |
| Everything else                   | `config`     |

**B) Commit type** by change type and content:

| Condition                                | Type             |
| ---------------------------------------- | ---------------- |
| New file (`??` or `A` in porcelain)      | `feat`           |
| Deleted file (`D`)                       | `feat` (removal) |
| `.dart` file modified                    | `fix`            |
| `pubspec.yaml` / `pubspec.lock`          | `chore`          |
| `.sql` or database migration files       | `fix`            |
| Test files (`*_test.dart`)               | `test`           |
| Markdown docs (`.md`)                    | `docs`           |
| `opencode.json` or `.opencode/`          | `chore`          |
| Config files (`.yaml`, `.json`, `.toml`) | `chore`          |
| Default                                  | `chore`          |

**C) Message description** — generate dynamically:

| Scenario                        | Description pattern                                                 |
| ------------------------------- | ------------------------------------------------------------------- |
| 1-2 files in group              | Describe briefly by filename (e.g., `correct payment registration`) |
| 3+ files in group               | `update <group> module`                                             |
| `pubspec.yaml` changed          | `update dependencies`                                               |
| `.database/` files changed      | `update database schema`                                            |
| Test files                      | `add tests for <group>`                                             |
| Only removed files              | `remove deprecated <group> code`                                    |
| Custom message provided by user | Use their message instead                                           |

**Format:** `<type>(<group>): <description>`

Examples:

- `feat(student): add payment registration screen`
- `fix(auth): correct last_access timestamp field`
- `chore: update dependencies`
- `fix(database): add payment trigger validation`
- `docs: update database schema comments`
- `test(auth): add login unit tests`

### Step 4: Stage & commit by group

Process groups in this order:

1. `core`
2. `database`
3. Feature groups (alphabetical: auth, cash_box, course, home, instructor, student, user)
4. `app`
5. `config`

For each group:

- `git add <file1> <file2> ...`
- `git commit -m "<message>"`

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

  1. <type>(<group>): <description>
  2. <type>(<group>): <description>
  ...
```

## Rules

- NEVER use `git push --force` or `git push -f`
- NEVER commit `.env`, secrets, or API keys
- ALWAYS use conventional commit format (`<type>(<scope>): <message>`)
- ALWAYS show the push summary
- If user provides a custom message, use it for ALL groups
- If user specifies a type (e.g., "haz un feat"), use that type globally
- Skip empty groups (no files to add)
- One commit per feature group, never mix features in the same commit
