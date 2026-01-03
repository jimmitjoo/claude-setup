---
argument-hint: "fil eller funktion att testa"
---

Använd test-writer agenten för att generera tester.

Om argument ges ($ARGUMENTS), generera tester för den specifika filen/funktionen.
Annars, analysera staged changes och föreslå tester.

Följ dessa principer:
1. **Testa beteende, inte implementation** - Vad ska hända, inte hur
2. **Arrange-Act-Assert** - Tydlig struktur
3. **Ett koncept per test** - Fokuserade tester
4. **Beskrivande namn** - "should return user when valid ID provided"
5. **Edge cases** - Tom input, gränsvärden, felfall

Inkludera:
- Unit tests för funktioner/metoder
- Integration tests för API-endpoints
- Edge cases och felhantering

Använd projektets befintliga testramverk och mönster.
