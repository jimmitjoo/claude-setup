---
argument-hint: "från version → till version"
---

Använd migrator-agenten för att planera och genomföra migrering.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits eller kommentarer.**

## Migreringstyper

### Version upgrade
```
/migrate node 18 → 20
/migrate react 17 → 18
/migrate next.js pages → app router
```

### Dependency update
```
/migrate update dependencies
/migrate update typescript
```

### Framework migration
```
/migrate express → fastify
/migrate class components → hooks
```

## Process

1. **Analys**
   - Nuvarande state
   - Målstate
   - Breaking changes

2. **Riskbedömning**
   - Vad kan gå fel?
   - Hur kritiskt är det?

3. **Migreringsplan**
   - Stegvis approach
   - Rollback-plan för varje steg

4. **Genomförande**
   - Ett steg i taget
   - Testa mellan varje steg

5. **Verifiering**
   - Alla tester passerar
   - Manuell verifiering av kritiska flöden

Om $ARGUMENTS anges, börja med den specifika migreringen.
Annars, analysera projektet och föreslå uppdateringar.
