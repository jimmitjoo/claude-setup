---
argument-hint: "fil eller område att refaktorera"
---

Analysera koden och föreslå refaktoreringar.

Om argument ges ($ARGUMENTS), fokusera på den specifika filen/området.
Annars, analysera hela projektet för refaktoreringsmöjligheter.

Kategorisera förslag:

## Enkla (snabba vinster)
- Byt namn för tydlighet
- Extrahera konstanter
- Ta bort död kod
- Förenkla conditionals

## Medelstora (timmar)
- Extrahera funktioner/metoder
- Konsolidera duplicerad kod
- Förbättra felhantering
- Optimera datastrukturer

## Stora (dagar)
- Arkitekturförändringar
- Byt ut bibliotek
- Omstrukturera moduler

För varje förslag, ange:
1. **Vad**: Konkret beskrivning
2. **Varför**: Motivering (läsbarhet, prestanda, underhåll)
3. **Risk**: Låg/Medium/Hög
4. **Hur**: Steg-för-steg approach
