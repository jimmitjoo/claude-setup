Använd security-reviewer agenten för att granska koden för säkerhetsproblem.

Kontrollera efter:
1. **Injection-attacker**: SQL, NoSQL, Command, XSS
2. **Autentisering**: Svaga lösenord, session-hantering
3. **Auktorisering**: Saknade access-kontroller, IDOR
4. **Dataexponering**: Känslig data i loggar, API-svar
5. **Konfiguration**: Hårdkodade secrets, debug-läge i prod
6. **Dependencies**: Kända sårbarheter (CVEs)

Om inget specifikt anges, granska staged changes eller hela projektet.

Formatera svaret med allvarlighetsgrad:
- 🔴 **Kritisk**: Måste åtgärdas omedelbart
- 🟠 **Hög**: Bör åtgärdas innan release
- 🟡 **Medium**: Bör åtgärdas
- 🟢 **Låg**: Kan förbättras
