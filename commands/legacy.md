---
argument-hint: "mapp eller beskrivning"
---

Använd legacy-analyst agenten för att analysera och dokumentera en okänd/gammal kodbas.

## Analysprocess

### 1. Första överblick
```
- Vilket språk/ramverk?
- Vilken era?
- Finns dokumentation?
- Finns tester?
- Hur startar man appen?
```

### 2. Kartlägg strukturen
```
- Entry points
- Routing
- Databasmodeller
- Externa integrationer
```

### 3. Identifiera risker
```
- Föråldrade dependencies
- Säkerhetsproblem
- Kod utan tester
- Hårdkodade credentials
```

### 4. Quick wins
```
- Enkla säkerhetsfixar
- Uppenbara förbättringar
- Dokumentation som saknas
```

## Output

```markdown
# [Projekt] - Legacy Analysis

## Översikt
- Språk/ramverk:
- Ålder (uppskattad):
- Hälsostatus: Bra/OK/Kritisk

## Struktur
[Mappstruktur med beskrivningar]

## Risker
| Risk | Allvarlighet | Åtgärd |

## Quick Wins
1. [ ] Enkel förbättring
2. [ ] ...

## Moderniseringsplan
### Fas 1: Stabilisera
### Fas 2: Tester
### Fas 3: Modernisera

## Hur köra lokalt
[Steg-för-steg instruktioner]
```

Om $ARGUMENTS anges, analysera den mappen/projektet.
Annars, analysera nuvarande projekt.
