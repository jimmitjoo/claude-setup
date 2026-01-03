# Claude Code Setup

Min personliga Claude Code-konfiguration för maximal produktivitet.

## Snabbinstallation

```bash
git clone https://github.com/jimmitjoo/claude-setup.git
cd claude-setup
./install.sh
```

## Innehåll

### 10 Agents
| Agent | Beskrivning |
|-------|-------------|
| `architect` | Systemdesign, tech stack-val |
| `code-reviewer` | Kodgranskning, anti-komplexitet |
| `debugger` | Systematisk felsökning |
| `devops` | CI/CD, Docker, deployment |
| `docs-writer` | Dokumentation |
| `legacy-analyst` | Analysera gamla kodbaser |
| `migrator` | Uppgraderingar, migrering |
| `performance-analyst` | Prestandaoptimering |
| `security-reviewer` | Säkerhetsgranskning |
| `test-writer` | Generera tester |

### 20 Skills
| Kategori | Skills |
|----------|--------|
| Frontend | typescript, react, nextjs, swift, kotlin |
| Backend | go, rust, laravel, python |
| Data | database, api-design, data-science, ml |
| Modern | llm-apps, edge, event-driven |
| Ops | devops, git, testing, legacy |

### 14 Commands
| Command | Beskrivning |
|---------|-------------|
| `/new [typ]` | Skapa nytt projekt |
| `/architect` | Designa system |
| `/review` | Kodgranskning |
| `/security` | Säkerhetsgranskning |
| `/test` | Generera tester |
| `/debug` | Felsökning |
| `/refactor` | Refaktorering |
| `/explain` | Förklara kod |
| `/migrate` | Migrera/uppgradera |
| `/deploy` | Deployment |
| `/estimate` | Estimera arbete |
| `/legacy` | Analysera legacy-kod |
| `/pr` | Skapa Pull Request |
| `/init` | Skapa CLAUDE.md |

## Projektmallar

```bash
# Frontend
/new react myapp
/new next myapp
/new expo myapp

# Backend
/new api myapi
/new api-go myapi
/new api-rust myapi
/new laravel myapp
/new fastapi myapi

# Fullstack
/new fullstack myapp
/new t3 myapp

# Specialiserade
/new ml mymodel
/new llm myrag
/new edge myworker
/new cli mytool
```

## Uppdatera

```bash
cd claude-setup
./update.sh
```

## Avinstallera

```bash
cd claude-setup
./uninstall.sh
```

## Anpassa

### Lägg till egna agents
```bash
# Skapa agent
nano ~/.claude/agents/my-agent.md
```

### Lägg till egna skills
```bash
# Skapa skill-katalog
mkdir ~/.claude/skills/my-skill
nano ~/.claude/skills/my-skill/SKILL.md
```

### Lägg till egna commands
```bash
# Skapa command
nano ~/.claude/commands/my-command.md
```

## Dokumentation

Full dokumentation finns i:
```bash
cat ~/.claude/README.md
```

## Licens

MIT
