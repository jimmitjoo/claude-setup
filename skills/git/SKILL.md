---
name: Git Expert
description: Git workflows, branching strategier, merge vs rebase, monorepo, och versionshantering.
---

# Git Best Practices

## Commit Messages

### Conventional Commits
```
type(scope): description

[optional body]

[optional footer]
```

### Typer
```
feat:     Ny funktionalitet
fix:      Buggfix
docs:     Dokumentation
style:    Formattering (ej kod-logik)
refactor: Omstrukturering utan ny funktionalitet
test:     Lägga till/ändra tester
chore:    Build, CI, dependencies
perf:     Prestandaförbättring
```

### Exempel
```
feat(auth): add password reset functionality

Implement password reset flow with email verification.
Token expires after 24 hours.

Closes #123
```

### Regler
- Imperativ form: "add" inte "added"
- Ingen punkt i slutet
- Max 72 tecken på första raden
- Förklara "varför" i body, inte "vad"
- **VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits eller PR-beskrivningar**

## Branching Strategier

### GitHub Flow (enkel)
```
main
  └── feature/add-login
  └── feature/user-profile
  └── fix/button-alignment
```
- `main` är alltid deploybar
- Feature branches från `main`
- PR → Review → Merge → Delete branch

### Git Flow (komplex)
```
main (production)
  └── develop
        └── feature/xxx
        └── release/1.2.0
  └── hotfix/critical-bug
```
- `main` = produktion
- `develop` = integration
- Feature branches från `develop`
- Release branches för förberedelse
- Hotfix direkt från `main`

### Trunk-Based (modern)
```
main
  └── short-lived feature branches (< 2 dagar)
```
- Alla jobbar mot `main`
- Små, frekventa merges
- Feature flags för WIP
- Continuous deployment

## Branch Naming
```
feature/add-user-authentication
bugfix/fix-login-redirect
hotfix/security-patch
docs/update-readme
refactor/simplify-cart-logic
test/add-checkout-tests
```

## Merge vs Rebase

### Merge (bevarar historik)
```bash
git checkout main
git merge feature/login
```
```
*   Merge branch 'feature/login'
|\
| * Add login validation
| * Create login form
|/
* Previous commit
```

### Rebase (linjär historik)
```bash
git checkout feature/login
git rebase main
git checkout main
git merge feature/login --ff-only
```
```
* Add login validation
* Create login form
* Previous commit
```

### När använda vad?
- **Merge**: Publika branches, bevara kontext
- **Rebase**: Lokala branches, innan PR, städa historik

## Vanliga operationer

### Ångra senaste commit (ej pushad)
```bash
git reset --soft HEAD~1  # Behåll ändringar staged
git reset --mixed HEAD~1 # Behåll ändringar unstaged
git reset --hard HEAD~1  # Radera ändringar
```

### Ändra senaste commit
```bash
git commit --amend -m "Ny message"
git commit --amend --no-edit  # Lägg till filer
```

### Cherry-pick
```bash
git cherry-pick abc123  # Kopiera specifik commit
```

### Stash
```bash
git stash                    # Spara ändringar
git stash pop                # Återställ senaste
git stash list               # Lista alla
git stash apply stash@{2}    # Återställ specifik
```

### Interaktiv rebase
```bash
git rebase -i HEAD~3

# I editorn:
pick abc123 First commit
squash def456 Second commit  # Slå ihop med föregående
reword ghi789 Third commit   # Ändra message
```

## .gitignore
```gitignore
# Dependencies
node_modules/
vendor/

# Build
dist/
build/
.next/

# Environment
.env
.env.local
.env*.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test
coverage/
```

## Git Hooks

### Pre-commit (lint)
```bash
#!/bin/sh
npm run lint-staged
```

### Commit-msg (validera format)
```bash
#!/bin/sh
npx commitlint --edit $1
```

### Med Husky
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  }
}
```

## Monorepo

### Struktur
```
monorepo/
├── packages/
│   ├── web/
│   ├── api/
│   └── shared/
├── package.json
└── pnpm-workspace.yaml
```

### pnpm workspace
```yaml
# pnpm-workspace.yaml
packages:
  - 'packages/*'
```

### Turborepo
```json
// turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"]
    }
  }
}
```

## Tips

### Se vad som ändrats
```bash
git diff                    # Unstaged
git diff --staged           # Staged
git diff main...feature     # Branch vs main
git log --oneline -10       # Senaste commits
git log --graph --oneline   # Visualisera branches
```

### Hitta vem som skrev
```bash
git blame path/to/file
git log -p path/to/file     # Historik för fil
```

### Sök i historik
```bash
git log --grep="fix"        # Sök i messages
git log -S "functionName"   # Sök i ändringar
```

### Rensa
```bash
git branch -d feature/done          # Ta bort mergad branch
git remote prune origin             # Ta bort stale remote branches
git gc                              # Garbage collection
```
