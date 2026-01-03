# Personliga Preferenser

## Språk & Kommunikation
- Föredrar svenska för kommunikation, engelska för kod och kommentarer
- Koncisa svar utan onödigt fluff
- Inga emojis om inte explicit begärt

## Kodstil

### Generellt
- 2 spaces indentation (inte tabs)
- Maximal radlängd: 100 tecken
- Föredrar explicita typer framför implicit typning
- Undvik kommentarer - skriv självdokumenterande kod istället

### Namngivning
- camelCase för variabler och funktioner
- PascalCase för klasser och komponenter
- SCREAMING_SNAKE_CASE för konstanter
- Beskrivande namn framför korta (getUserById > getUser)

### Git
- Conventional commits: `type(scope): description`
- Typer: feat, fix, docs, style, refactor, test, chore
- Branch-namn: `feature/`, `bugfix/`, `hotfix/`, `docs/`
- Squash commits före merge till main
- **VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits, PR-beskrivningar eller kodkommentarer**

### Arbetsflöde - Git som versionshantering, inte filnamn
- **ALDRIG** parallella filer (script-v1.sh, script-alt.sh) - använd git istället
- Vid ny approach: commit → radera → implementera ny → testa
- Om ny approach misslyckas: `git checkout` för att återställa
- **Git worktrees för parallella experiment:**
  - `git worktree add ../projekt-experiment experiment/feature-x`
  - Subagenter kan jobba i olika worktrees samtidigt
  - Jämför resultat, behåll bästa, ta bort resten
  - `git worktree remove ../projekt-experiment`

## Verktyg & Preferenser
- pnpm > yarn > npm
- Vitest för testning
- ESLint + Prettier för linting/formattering
- TypeScript strikt mode

## Principer
- YAGNI - You Ain't Gonna Need It
- KISS - Keep It Simple, Stupid
- DRY - men duplicering är OK tills mönster uppstår (3+ gånger)
- Testa beteende, inte implementation
