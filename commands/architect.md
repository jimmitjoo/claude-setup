---
argument-hint: "feature eller system att designa"
---

Använd architect-agenten för att designa systemarkitektur innan implementation.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i dokumentation.**

## När använda

- Ny feature som påverkar flera delar
- Nytt projekt/system
- Stor refaktorering
- Osäker på bästa approach

## Output

### Arkitekturdokument
```markdown
# [Feature/System] Arkitektur

## Översikt
Kort beskrivning

## Krav
### Funktionella
- [ ] Krav 1

### Icke-funktionella
- Prestanda, skalbarhet, etc.

## Tech Stack
| Komponent | Teknologi | Motivering |

## Komponenter
[Beskrivning av varje del]

## Datamodell
[Entiteter och relationer]

## API Design
[Endpoints och kontrakt]

## Risker och trade-offs
[Vad kan gå fel, vad offrar vi]
```

## Frågor att besvara

1. Vem är användarna?
2. Vilken skala pratar vi om?
3. Vilka constraints finns? (tid, budget, kompetens)
4. Vad ska integreras med?
5. Vad är viktigast: snabbhet, skalbarhet, enkelhet?

Om $ARGUMENTS anges, designa den specifika featuren/systemet.
Annars, fråga vad som ska designas.
