---
name: TypeScript Expert
description: Best practices för TypeScript-utveckling med fokus på typsäkerhet, moderna mönster och strikt konfiguration.
---

# TypeScript Best Practices

## Strikt Konfiguration

Använd alltid strikt TypeScript:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## Typning

### Föredra explicita typer för publika API:er
```typescript
// Bra - explicit returtyp
function getUser(id: string): Promise<User | null> {
  return db.users.find(id);
}

// Undvik - implicit returtyp för publika funktioner
function getUser(id: string) {
  return db.users.find(id);
}
```

### Använd `unknown` istället för `any`
```typescript
// Bra
function parseJSON(data: string): unknown {
  return JSON.parse(data);
}

// Undvik
function parseJSON(data: string): any {
  return JSON.parse(data);
}
```

### Discriminated Unions för states
```typescript
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

### Const assertions för literals
```typescript
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number]; // 'admin' | 'user' | 'guest'
```

## Mönster

### Använd `satisfies` för typvalidering med inference
```typescript
const config = {
  port: 3000,
  host: 'localhost',
} satisfies Config;
// config.port är number, inte number | undefined
```

### Branded types för domänvalidering
```typescript
type UserId = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}
```

### Utility types
```typescript
// Partial, Required, Pick, Omit, Record
type UpdateUserInput = Partial<Omit<User, 'id' | 'createdAt'>>;

// ReturnType, Parameters
type GetUserReturn = ReturnType<typeof getUser>;
```

## Undvik

- `any` - använd `unknown` och typguards
- Type assertions (`as`) - validera istället
- `!` non-null assertion - hantera null-fallet
- `@ts-ignore` - fixa typproblemet istället
- Enum - använd union types eller const objects
