---
argument-hint: "felbeskrivning eller fil"
---

Använd debugger-agenten för att systematiskt felsöka problemet.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits eller kommentarer.**

## Process

1. **Förstå problemet**
   - Vad är förväntat beteende?
   - Vad händer faktiskt?
   - Kan det reproduceras?

2. **Samla information**
   - Felmeddelanden
   - Stack traces
   - Relevanta loggar
   - Senaste ändringar (git log)

3. **Formulera hypoteser**
   - Baserat på symptomen, vad kan orsaken vara?
   - Prioritera efter sannolikhet

4. **Testa hypoteser**
   - Verifiera eller falsifiera en åt gången

5. **Fixa och verifiera**
   - Minimal fix
   - Lägg till test som fångar buggen
   - Verifiera att problemet är löst

Om argument ges ($ARGUMENTS), börja med att analysera det specifika problemet.
Annars, fråga efter symptom och kontext.
