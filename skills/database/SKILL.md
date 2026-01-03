---
name: Database Expert
description: SQL och NoSQL databaser, queries, indexering, och optimering.
---

# Database Best Practices

## Schema Design

### Normalisering (SQL)
```sql
-- Bra: Normaliserad struktur
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Index strategiskt
```sql
-- Index på kolumner som används i WHERE, JOIN, ORDER BY
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite index för vanliga query-mönster
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
```

## Query Patterns

### Undvik N+1
```typescript
// Dåligt - N+1 queries
const users = await db.users.findMany();
for (const user of users) {
  user.posts = await db.posts.findMany({ where: { userId: user.id } });
}

// Bra - Single query med JOIN
const users = await db.users.findMany({
  include: { posts: true }
});
```

### Paginering
```sql
-- Offset pagination (enkel men långsam för stora offsets)
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;

-- Cursor pagination (effektivare)
SELECT * FROM posts
WHERE created_at < $cursor
ORDER BY created_at DESC
LIMIT 20;
```

### Transactions
```typescript
await db.$transaction(async (tx) => {
  const user = await tx.users.create({ data: userData });
  await tx.accounts.create({
    data: { userId: user.id, balance: 0 }
  });
  return user;
});
```

## Prisma (ORM)

### Schema
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String?
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())

  @@index([authorId])
  @@index([createdAt(sort: Desc)])
}
```

### Queries
```typescript
// Filtrera och inkludera relationer
const users = await prisma.user.findMany({
  where: {
    email: { endsWith: '@company.com' }
  },
  include: {
    posts: {
      take: 5,
      orderBy: { createdAt: 'desc' }
    }
  },
});

// Upsert
await prisma.user.upsert({
  where: { email: 'user@example.com' },
  create: { email: 'user@example.com', name: 'New User' },
  update: { name: 'Updated User' },
});
```

## MongoDB / NoSQL

### Schema design
```typescript
// Embed för 1:few relationer
interface User {
  _id: ObjectId;
  email: string;
  addresses: Address[]; // Embedded
}

// Reference för 1:many eller many:many
interface Post {
  _id: ObjectId;
  authorId: ObjectId; // Reference
  title: string;
}
```

### Indexes
```javascript
db.posts.createIndex({ authorId: 1 });
db.posts.createIndex({ createdAt: -1 });
db.posts.createIndex({ title: "text", content: "text" }); // Text search
```

## Optimering

### EXPLAIN för query analysis
```sql
EXPLAIN ANALYZE
SELECT * FROM posts
WHERE user_id = '123'
ORDER BY created_at DESC;
```

### Connection pooling
```typescript
// Prisma - connection limit
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL + '?connection_limit=5',
    },
  },
});
```

## Migrations

### Säker migration
```sql
-- Lägg till kolumn med default (icke-blockerande)
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Skapa index concurrently (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_status ON users(status);
```

### Rollback plan
- Testa migrations på staging först
- Ha alltid en down-migration redo
- Undvik destruktiva ändringar i produktion
