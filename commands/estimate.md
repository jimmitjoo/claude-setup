---
argument-hint: "feature eller uppgift"
---

Analysera och estimera komplexitet för en uppgift.

## Estimeringsmodell

### T-shirt sizes
```
XS  - Trivial, < 1 timme
S   - Enkel, några timmar
M   - Medium, 1-2 dagar
L   - Stor, 3-5 dagar
XL  - Mycket stor, 1-2 veckor
XXL - Episk, behöver brytas ner
```

## Analys

### 1. Scope
- Vad ingår?
- Vad ingår INTE?
- Vilka antaganden görs?

### 2. Komplexitetsfaktorer
- Ny kod vs ändra befintlig
- Beroenden till andra system
- Tester som behövs
- Dokumentation
- Review och iteration

### 3. Risker
- Okända okända
- Teknisk osäkerhet
- Externa beroenden

### 4. Breakdown
```
Feature X (M)
├── Backend API (S)
│   ├── Endpoint 1 (XS)
│   └── Endpoint 2 (XS)
├── Frontend UI (S)
│   ├── Komponent A (XS)
│   └── Komponent B (XS)
├── Tester (S)
└── Dokumentation (XS)
```

## Output

```markdown
# Estimat: [Feature]

## Sammanfattning
- **Total storlek:** M (1-2 dagar)
- **Osäkerhet:** Medium
- **Risker:** [lista]

## Breakdown
[Hierarkisk lista med deluppgifter]

## Antaganden
- [antagande 1]
- [antagande 2]

## Frågor att klargöra
- [fråga som påverkar estimatet]
```

Om $ARGUMENTS anges, estimera den uppgiften.
Annars, fråga vad som ska estimeras.
