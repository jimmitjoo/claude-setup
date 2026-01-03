---
name: Testing Expert
description: Teststrategi, test-driven development, unit/integration/e2e tester oberoende av språk.
---

# Testing Best Practices

## Testpyramiden

```
        /\
       /  \      E2E (få)
      /----\     - Långsamma
     /      \    - Kritiska user journeys
    /--------\   Integration (medium)
   /          \  - API, databas
  /------------\ Unit (många)
 /              \- Snabba, isolerade
```

## Principer

### 1. Testa beteende, inte implementation
```typescript
// ❌ Testar implementation
expect(user._hashedPassword).toMatch(/^\$2b\$/);

// ✅ Testar beteende
expect(await user.verifyPassword('correct')).toBe(true);
expect(await user.verifyPassword('wrong')).toBe(false);
```

### 2. Arrange-Act-Assert
```typescript
it('should calculate total with discount', () => {
  // Arrange
  const cart = new Cart();
  cart.addItem({ price: 100, quantity: 2 });
  cart.applyDiscount(0.1);

  // Act
  const total = cart.getTotal();

  // Assert
  expect(total).toBe(180);
});
```

### 3. Ett koncept per test
```typescript
// ❌ Testar för mycket
it('should handle user operations', () => {
  expect(createUser()).toBeDefined();
  expect(updateUser()).toBeDefined();
  expect(deleteUser()).toBeDefined();
});

// ✅ Fokuserade tester
it('should create user with valid data', () => { ... });
it('should update user email', () => { ... });
it('should soft delete user', () => { ... });
```

### 4. Beskrivande namn
```typescript
// ❌ Vagt
it('works', () => { ... });
it('test user', () => { ... });

// ✅ Beskrivande
it('should return 404 when user does not exist', () => { ... });
it('should hash password before saving', () => { ... });
```

## Unit Tests

### Isolerade, snabba
```typescript
describe('calculatePrice', () => {
  it('applies percentage discount', () => {
    expect(calculatePrice(100, { type: 'percent', value: 20 })).toBe(80);
  });

  it('applies fixed discount', () => {
    expect(calculatePrice(100, { type: 'fixed', value: 15 })).toBe(85);
  });

  it('never goes below zero', () => {
    expect(calculatePrice(10, { type: 'fixed', value: 50 })).toBe(0);
  });
});
```

### Mocking
```typescript
// Mock externa dependencies
const mockEmailService = {
  send: vi.fn().mockResolvedValue({ id: '123' }),
};

const userService = new UserService(mockEmailService);
await userService.register({ email: 'test@example.com' });

expect(mockEmailService.send).toHaveBeenCalledWith(
  expect.objectContaining({ to: 'test@example.com' })
);
```

## Integration Tests

### API tester
```typescript
describe('POST /api/users', () => {
  it('creates user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test' });

    expect(response.status).toBe(201);
    expect(response.body.data.email).toBe('test@example.com');
  });

  it('returns 422 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Test' });

    expect(response.status).toBe(422);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

### Databas tester
```typescript
beforeEach(async () => {
  await db.migrate.latest();
  await db.seed.run();
});

afterEach(async () => {
  await db.migrate.rollback();
});

it('finds user by email', async () => {
  const user = await userRepository.findByEmail('test@example.com');
  expect(user).toBeDefined();
  expect(user.name).toBe('Test User');
});
```

## E2E Tests

### Playwright
```typescript
test('user can log in', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('h1')).toContainText('Welcome');
});
```

### Cypress
```typescript
describe('Login', () => {
  it('logs in successfully', () => {
    cy.visit('/login');
    cy.get('[name="email"]').type('user@example.com');
    cy.get('[name="password"]').type('password');
    cy.get('button[type="submit"]').click();

    cy.url().should('include', '/dashboard');
    cy.contains('h1', 'Welcome');
  });
});
```

## Test Data

### Factories
```typescript
const userFactory = {
  build: (overrides = {}) => ({
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    createdAt: new Date(),
    ...overrides,
  }),

  create: async (overrides = {}) => {
    const user = userFactory.build(overrides);
    return db.users.create(user);
  },
};

// Användning
const user = userFactory.build({ name: 'Custom Name' });
const savedUser = await userFactory.create();
```

### Fixtures
```typescript
// fixtures/users.json
{
  "admin": {
    "email": "admin@example.com",
    "role": "admin"
  },
  "user": {
    "email": "user@example.com",
    "role": "user"
  }
}
```

## Edge Cases att testa

- Tom input
- Null/undefined
- Tomma arrays/objekt
- Gränsvärden (0, -1, MAX)
- Unicode och specialtecken
- Stora datamängder
- Concurrent access
- Nätverksfel
- Timeout
- Invalid state transitions

## Test Coverage

### Vad som är viktigt
- Kritiska business paths
- Edge cases
- Felhantering

### Vad som är mindre viktigt
- Getters/setters
- Konstanter
- Boilerplate

### Mål
- 80% är ofta en bra balans
- 100% är sällan värt det
- Fokusera på kvalitet, inte kvantitet
