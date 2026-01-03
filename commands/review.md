Använd code-reviewer agenten för att granska koden.

Fokusera på:
1. Onödig komplexitet och abstraktioner
2. Kod som kan förenklas
3. Prematura optimeringar
4. Design patterns utan tydligt syfte
5. "Clever" kod som borde vara enkel

Om inget specifikt anges, granska staged changes (git diff --cached) eller senaste ändringarna.

Formatera svaret som:
- **Röda flaggor**: Problem som bör åtgärdas
- **Förslag**: Konkreta förenklingar
- **Bra**: Saker som är väl gjorda
