---
name: Database Expert
description: SQL och NoSQL databaser, queries, indexering, och optimering.
---

# Database Best Practices

## Databasval
- **PostgreSQL** - förstaval för de flesta projekt
- **SQLite** - enklare appar, edge/embedded
- **Turso** - edge SQLite med replikering

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
const users = await db.query.users.findMany();
for (const user of users) {
  user.posts = await db.query.posts.findMany({ where: eq(posts.userId, user.id) });
}

// Bra - Single query med relations
const users = await db.query.users.findMany({
  with: { posts: true }
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

## Drizzle ORM (föredra)

Lättviktigt, typsäkert, nära SQL.

### Schema
```typescript
// schema.ts
import { pgTable, uuid, varchar, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).unique().notNull(),
  name: varchar('name', { length: 100 }).notNull(),
  createdAt: timestamp('created_at').defaultNow(),
});

export const posts = pgTable('posts', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: varchar('title', { length: 255 }).notNull(),
  content: text('content'),
  authorId: uuid('author_id').references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow(),
});
```

### Queries
```typescript
import { eq, desc } from 'drizzle-orm';
import { db } from './db';
import { users, posts } from './schema';

// Select med filter
const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.email, 'user@company.com'));

// Join
const usersWithPosts = await db
  .select()
  .from(users)
  .leftJoin(posts, eq(users.id, posts.authorId))
  .orderBy(desc(posts.createdAt));

// Insert
await db.insert(users).values({
  email: 'new@example.com',
  name: 'New User',
});

// Upsert
await db
  .insert(users)
  .values({ email: 'user@example.com', name: 'New User' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'Updated User' },
  });

// Transaction
await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values(userData).returning();
  await tx.insert(accounts).values({ userId: user.id, balance: 0 });
  return user;
});
```

### Relationer (query style)
```typescript
import { relations } from 'drizzle-orm';

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}));

// Använd med query
const usersWithPosts = await db.query.users.findMany({
  with: { posts: { limit: 5 } },
});
```

## Prisma (prototyper)

OK för snabb MVP, men Drizzle föredras för produktion.

```typescript
// Prisma är mer "magiskt" men tyngre
const users = await prisma.user.findMany({
  include: { posts: true }
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
