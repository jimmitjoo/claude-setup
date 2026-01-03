---
name: Next.js Expert
description: Next.js App Router, Server Components, Server Actions, och fullstack React.
---

# Next.js Best Practices

## Projektstruktur (App Router)

```
app/
├── (auth)/                    # Route group (ingen URL-påverkan)
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (dashboard)/
│   ├── layout.tsx             # Shared layout
│   ├── page.tsx               # /dashboard
│   └── settings/
│       └── page.tsx           # /dashboard/settings
├── api/
│   └── users/
│       └── route.ts           # API route
├── layout.tsx                 # Root layout
├── page.tsx                   # Home page
├── loading.tsx                # Loading UI
├── error.tsx                  # Error boundary
└── not-found.tsx              # 404 page

components/
├── ui/                        # Generiska UI components
└── features/                  # Feature-specifika

lib/
├── db.ts                      # Database client
├── auth.ts                    # Auth utilities
└── utils.ts                   # Helpers
```

## Server Components (default)

```tsx
// app/users/page.tsx
// Server Component - ingen "use client"
async function UsersPage() {
  const users = await db.user.findMany();

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}

export default UsersPage;
```

### När använda Server Components
- Data fetching
- Tillgång till backend resources
- Känslig logik (API keys, tokens)
- Stora dependencies

## Client Components

```tsx
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}
```

### När använda Client Components
- useState, useEffect, hooks
- Event handlers (onClick, onChange)
- Browser APIs
- Interaktivitet

## Data Fetching

### I Server Components
```tsx
async function Page() {
  // Cacheas automatiskt
  const data = await fetch('https://api.example.com/data');

  // Ingen cache
  const fresh = await fetch('https://api.example.com/data', {
    cache: 'no-store'
  });

  // Revalidate varje timme
  const timed = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 }
  });

  return <div>{/* ... */}</div>;
}
```

### Parallell data fetching
```tsx
async function Page() {
  // Parallellt - snabbare!
  const [users, posts] = await Promise.all([
    getUsers(),
    getPosts()
  ]);

  return <div>{/* ... */}</div>;
}
```

## Server Actions

```tsx
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  await db.user.create({ data: { name, email } });

  revalidatePath('/users');
}

// app/users/new/page.tsx
import { createUser } from '../actions';

export default function NewUserPage() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

### Med validering
```tsx
'use server';

import { z } from 'zod';

const schema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
});

export async function createUser(formData: FormData) {
  const result = schema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  });

  if (!result.success) {
    return { error: result.error.flatten() };
  }

  await db.user.create({ data: result.data });
  revalidatePath('/users');
  return { success: true };
}
```

## Layouts

### Root Layout (required)
```tsx
// app/layout.tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="sv">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
```

### Nested Layouts
```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}
```

## Loading & Error States

### Loading
```tsx
// app/users/loading.tsx
export default function Loading() {
  return <Skeleton />;
}
```

### Error
```tsx
// app/users/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Middleware

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Auth check
  const token = request.cookies.get('token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*'],
};
```

## API Routes

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET() {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}

// app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 });
  }

  return NextResponse.json(user);
}
```

## Metadata

```tsx
// Static
export const metadata = {
  title: 'My App',
  description: 'Description',
};

// Dynamic
export async function generateMetadata({ params }) {
  const post = await getPost(params.id);
  return {
    title: post.title,
    description: post.excerpt,
  };
}
```

## Optimizations

### Image
```tsx
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority  // Preload för LCP
/>
```

### Link (prefetch)
```tsx
import Link from 'next/link';

<Link href="/about">About</Link>  // Prefetch by default
```

### Dynamic imports
```tsx
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />,
});
```
