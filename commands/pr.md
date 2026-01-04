---
description: Skapa en Pull Request för nuvarande ändringar
argument-hint: "branch eller beskrivning (optional)"
---

Skapa en Pull Request för nuvarande ändringar.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI eller liknande i commits eller PR-beskrivningar. Skriv som om du är utvecklaren själv.**

1. **Analysera ändringar**
   - Kör `git diff main...HEAD` (eller angiven branch)
   - Sammanfatta vad som ändrats

2. **Generera PR-beskrivning**

## Sammanfattning
[2-3 meningar som beskriver ändringen]

## Ändringar
- [Bullet points med konkreta ändringar]

## Typ av ändring
- [ ] Bugfix
- [ ] Ny feature
- [ ] Breaking change
- [ ] Dokumentation
- [ ] Refaktorering

## Testning
- [ ] Nya tester tillagda
- [ ] Befintliga tester passerar
- [ ] Manuellt testat

## Screenshots (om relevant)
[Lägg till screenshots för UI-ändringar]

3. **Skapa PR via GitHub CLI**
   ```bash
   gh pr create --title "..." --body "..."
   ```

Fråga om titel och beskrivning ser bra ut innan PR skapas.
