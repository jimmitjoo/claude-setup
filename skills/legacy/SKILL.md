---
name: Legacy Code Expert
description: Hantera äldre kodbaser, vanliga legacy patterns, upgrade paths, och moderniseringsstrategier.
---

# Legacy Code Best Practices

## Första Stegen

### 1. Få det att köra
```bash
# Dokumentera allt du gör för att få igång projektet
# Framtida du kommer tacka dig

# Vanliga problem:
# - Saknade dependencies
# - Fel versioner
# - Miljövariabler
# - Databas setup
```

### 2. Förstå strukturen
```bash
# Hitta entry points
find . -name "index.*" -o -name "main.*" -o -name "app.*"

# Hitta routing
grep -r "route\|router\|get\|post" --include="*.php" --include="*.py" --include="*.js"

# Hitta databasanvändning
grep -r "SELECT\|INSERT\|query\|execute" --include="*.php" --include="*.py"
```

### 3. Kartlägg dependencies
```bash
# JavaScript
cat package.json | jq '.dependencies'
npm outdated

# Python
pip list --outdated
pip-audit

# PHP
composer outdated
composer audit
```

## Vanliga Legacy Patterns

### PHP (pre-framework)

#### Problem: Inline SQL
```php
// ❌ Farligt
$result = mysql_query("SELECT * FROM users WHERE id = " . $_GET['id']);

// ✅ Fix med PDO
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$_GET['id']]);
```

#### Problem: include-spaghetti
```php
// ❌ Svårt att följa
include 'header.php';
include '../lib/db.php';
include $page . '.php';

// ✅ Autoloading
require 'vendor/autoload.php';
use App\Controllers\PageController;
```

### jQuery Legacy

#### Problem: DOM som state
```javascript
// ❌ State i DOM
$('#user-name').text(name);
$('#user-email').text(email);
// ...senare...
var name = $('#user-name').text(); // Läser från DOM

// ✅ Separera data och presentation
const state = { name, email };
render(state);
```

#### Problem: Callback hell
```javascript
// ❌ Pyramid of doom
$.get('/user', function(user) {
  $.get('/posts/' + user.id, function(posts) {
    $.get('/comments/' + posts[0].id, function(comments) {
      // ...
    });
  });
});

// ✅ Promises/async
const user = await fetch('/user').then(r => r.json());
const posts = await fetch(`/posts/${user.id}`).then(r => r.json());
const comments = await fetch(`/comments/${posts[0].id}`).then(r => r.json());
```

### Old Java

#### Problem: XML överallt
```xml
<!-- ❌ XML config -->
<bean id="userService" class="com.example.UserService">
  <property name="userDao" ref="userDao"/>
</bean>
```
```java
// ✅ Annotations
@Service
public class UserService {
    @Autowired
    private UserDao userDao;
}
```

### Old .NET

#### Problem: Web Forms
```aspx
<!-- ❌ ViewState, PostBack -->
<asp:GridView ID="UsersGrid" runat="server" OnRowCommand="UsersGrid_RowCommand">
```
```csharp
// ✅ MVC/Razor Pages
public class UsersController : Controller {
    public IActionResult Index() => View(_userService.GetAll());
}
```

## Moderniseringsstrategi

### Strangler Fig Pattern
```
1. Identifiera en del att modernisera
2. Bygg ny implementation vid sidan av
3. Dirigera trafik till nya versionen
4. Ta bort gamla när den är ersatt
5. Upprepa

Gammal app: [A][B][C][D]
            ↓
Steg 1:     [A][B][C][D]
                 [B']     ← Ny implementation
            ↓
Steg 2:     [A]   [C][D]  ← Trafik till B'
               [B']
            ↓
Steg 3:     [A][B'][C'][D']  ← Allt moderniserat
```

### Feature Flags
```javascript
if (featureFlags.useNewCheckout) {
  return newCheckoutFlow();
} else {
  return legacyCheckout();
}
```

### Anti-Corruption Layer
```
Legacy System  ←→  [ACL]  ←→  New System

ACL översätter mellan gamla och nya modeller
så att ny kod inte "smittas" av legacy patterns
```

## Säkerhetsproblem att fixa

### Kritiska (fixa först!)
```php
// SQL Injection
$pdo->prepare("SELECT * FROM users WHERE id = ?");

// XSS
htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');

// Command Injection
escapeshellarg($userInput);

// Path Traversal
realpath($path) && strpos(realpath($path), $allowedDir) === 0;
```

### Viktiga
```php
// Session fixation
session_regenerate_id(true);

// CSRF
// Lägg till CSRF-tokens i forms

// Insecure password storage
password_hash($password, PASSWORD_DEFAULT);
password_verify($input, $hash);
```

## Upgrade Paths

### PHP
```
PHP 5.6 → 7.0 (stora ändringar)
  - mysql_* borta → PDO
  - mcrypt borta → OpenSSL
  - Striktare typer

PHP 7.x → 8.0 (stora ändringar)
  - Named arguments
  - Attributes
  - Constructor promotion
  - match expression
```

### Node.js
```
LTS versions:
  - 14 → 16 → 18 → 20 → 22

Vanliga breaking changes:
  - CommonJS → ES Modules
  - Callback → Promises → async/await
```

### Python
```
Python 2 → 3 (stort!)
  - print() function
  - Unicode by default
  - Integer division

Python 3.x upgrades:
  - f-strings (3.6)
  - dataclasses (3.7)
  - walrus operator (3.8)
  - pattern matching (3.10)
```

## Tester för Legacy

### Karakteriseringstester
```python
# Dokumentera nuvarande beteende
# (även om det är "fel")

def test_legacy_date_parsing():
    # Systemet parsar datum på detta sätt
    # Vi testar för att fånga om vi ändrar beteende
    result = legacy_parse_date("2023-13-45")
    assert result == "2024-02-14"  # Ja, det är så det funkar
```

### Golden Master Testing
```python
# Spara output för att jämföra
def test_report_generation():
    output = generate_report(test_data)

    with open('golden/report.txt') as f:
        expected = f.read()

    assert output == expected
```

## Dokumentera medan du går

```markdown
# [System] - Legacy Analysis

## Vad jag lärt mig
- Entry point är X
- Routing fungerar via Y
- Databas är Z

## Gotchas
- Funktion A gör inte vad namnet säger
- Config B måste sättas annars kraschar det
- Aldrig rör fil C utan att testa

## Hur man kör
1. Steg 1
2. Steg 2

## Kända buggar
- Bug 1: Beskrivning, workaround
```
