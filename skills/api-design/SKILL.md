---
name: API Design Expert
description: RESTful API design, felhantering, validering och dokumentation.
---

# API Design Best Practices

## RESTful Konventioner

### Resurser (nouns, plural)
```
GET    /users          - Lista alla användare
GET    /users/:id      - Hämta en användare
POST   /users          - Skapa användare
PUT    /users/:id      - Uppdatera användare (hela resursen)
PATCH  /users/:id      - Uppdatera användare (delvis)
DELETE /users/:id      - Ta bort användare
```

### Nesting för relationer
```
GET    /users/:id/posts        - Användarens inlägg
POST   /users/:id/posts        - Skapa inlägg för användare
GET    /posts/:id/comments     - Inläggets kommentarer
```

### Query parameters för filtrering/paginering
```
GET /users?role=admin&status=active
GET /users?page=2&limit=20
GET /users?sort=createdAt&order=desc
GET /users?fields=id,name,email
```

## HTTP Status Codes

### Success
- `200 OK` - GET, PUT, PATCH lyckades
- `201 Created` - POST lyckades, returnera `Location` header
- `204 No Content` - DELETE lyckades, ingen body

### Client Errors
- `400 Bad Request` - Ogiltig request body/parametrar
- `401 Unauthorized` - Autentisering saknas/ogiltig
- `403 Forbidden` - Autentiserad men ej behörig
- `404 Not Found` - Resurs finns inte
- `409 Conflict` - Konflikt (t.ex. duplicate)
- `422 Unprocessable Entity` - Validering misslyckades

### Server Errors
- `500 Internal Server Error` - Oväntat serverfel
- `503 Service Unavailable` - Tjänst ej tillgänglig

## Felhantering

### Konsekvent felformat
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Logga internt, exponera inte stacktraces
```typescript
app.use((err, req, res, next) => {
  logger.error(err.stack);

  res.status(err.status || 500).json({
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.expose ? err.message : 'An error occurred',
    },
  });
});
```

## Validering

### Validera tidigt, returnera alla fel
```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  age: z.number().int().min(18).optional(),
});

function createUser(req, res) {
  const result = CreateUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(422).json({
      error: {
        code: 'VALIDATION_ERROR',
        details: result.error.issues,
      },
    });
  }
  // ...
}
```

## Versioning

### URL prefix (rekommenderat för tydlighet)
```
/api/v1/users
/api/v2/users
```

### Header (alternativ)
```
Accept: application/vnd.myapi.v2+json
```

## Säkerhet

- Rate limiting på alla endpoints
- Input validering och sanitering
- HTTPS endast
- CORS konfiguration
- Autentisering via Bearer tokens
- Auktorisering på resursnivå

## Dokumentation

### OpenAPI/Swagger
```yaml
paths:
  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: User found
        '404':
          description: User not found
```
