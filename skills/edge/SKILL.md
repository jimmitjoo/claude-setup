---
name: Edge & Serverless Expert
description: Cloudflare Workers, Vercel Edge, Deno Deploy, AWS Lambda, och moderna edge-first patterns.
---

# Edge & Serverless Best Practices

## Varför Edge?

```
Traditionell:    User → CDN → Origin Server (100-500ms)
Edge:            User → Edge (10-50ms)

- Lägre latency (nära användaren)
- Automatisk skalning
- Billigare (betala per request)
- Bättre för globala användare
```

## Cloudflare Workers

### Basic Worker
```typescript
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/api/hello") {
      return Response.json({ message: "Hello from the edge!" });
    }

    if (url.pathname.startsWith("/api/")) {
      return handleApi(request, env);
    }

    // Fallback till origin
    return fetch(request);
  },
};

async function handleApi(request: Request, env: Env): Promise<Response> {
  try {
    const data = await request.json();
    // Process...
    return Response.json({ success: true });
  } catch (error) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }
}
```

### KV Storage
```typescript
interface Env {
  MY_KV: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const key = url.pathname.slice(1);

    if (request.method === "GET") {
      const value = await env.MY_KV.get(key);
      if (!value) {
        return new Response("Not found", { status: 404 });
      }
      return new Response(value);
    }

    if (request.method === "PUT") {
      const value = await request.text();
      await env.MY_KV.put(key, value, {
        expirationTtl: 60 * 60 * 24, // 24 timmar
      });
      return new Response("Saved");
    }

    return new Response("Method not allowed", { status: 405 });
  },
};
```

### Durable Objects (stateful edge)
```typescript
export class Counter {
  private state: DurableObjectState;
  private value: number = 0;

  constructor(state: DurableObjectState) {
    this.state = state;
  }

  async fetch(request: Request): Promise<Response> {
    // Ladda från storage
    this.value = (await this.state.storage.get("value")) || 0;

    const url = new URL(request.url);

    if (url.pathname === "/increment") {
      this.value++;
      await this.state.storage.put("value", this.value);
    }

    return Response.json({ value: this.value });
  }
}

// Worker som använder Durable Object
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const id = env.COUNTER.idFromName("global");
    const counter = env.COUNTER.get(id);
    return counter.fetch(request);
  },
};
```

### D1 Database (SQLite på edge)
```typescript
interface Env {
  DB: D1Database;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Query
    const { results } = await env.DB.prepare(
      "SELECT * FROM users WHERE id = ?"
    ).bind(userId).all();

    // Insert
    await env.DB.prepare(
      "INSERT INTO users (name, email) VALUES (?, ?)"
    ).bind(name, email).run();

    // Batch
    const batch = [
      env.DB.prepare("INSERT INTO logs (msg) VALUES (?)").bind("log1"),
      env.DB.prepare("INSERT INTO logs (msg) VALUES (?)").bind("log2"),
    ];
    await env.DB.batch(batch);

    return Response.json(results);
  },
};
```

## Vercel Edge Functions

### Edge API Route
```typescript
// app/api/hello/route.ts
import { NextRequest } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const name = searchParams.get('name') || 'World';

  return Response.json({
    message: `Hello, ${name}!`,
    region: process.env.VERCEL_REGION,
  });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  // Process...
  return Response.json({ received: body });
}
```

### Edge Middleware
```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Geolocation
  const country = request.geo?.country || 'SE';

  // A/B testing
  const bucket = Math.random() < 0.5 ? 'a' : 'b';

  // Bot detection
  const isBot = /bot|crawler|spider/i.test(
    request.headers.get('user-agent') || ''
  );

  if (isBot) {
    return new NextResponse('Forbidden', { status: 403 });
  }

  // Add headers
  const response = NextResponse.next();
  response.headers.set('x-country', country);
  response.headers.set('x-bucket', bucket);

  return response;
}

export const config = {
  matcher: ['/api/:path*', '/app/:path*'],
};
```

### Edge Config (feature flags)
```typescript
import { get } from '@vercel/edge-config';

export const runtime = 'edge';

export async function GET() {
  const showBanner = await get('showBanner');
  const maintenance = await get('maintenance');

  if (maintenance) {
    return Response.json({ error: 'Maintenance mode' }, { status: 503 });
  }

  return Response.json({ showBanner });
}
```

## Deno Deploy

### Basic Server
```typescript
// main.ts
Deno.serve(async (request: Request) => {
  const url = new URL(request.url);

  if (url.pathname === "/") {
    return new Response("Hello from Deno Deploy!");
  }

  if (url.pathname === "/api/data") {
    const data = { time: new Date().toISOString() };
    return Response.json(data);
  }

  return new Response("Not Found", { status: 404 });
});
```

### Med Deno KV
```typescript
const kv = await Deno.openKv();

Deno.serve(async (request: Request) => {
  const url = new URL(request.url);

  if (request.method === "GET") {
    const result = await kv.get(["users", url.pathname]);
    if (!result.value) {
      return new Response("Not found", { status: 404 });
    }
    return Response.json(result.value);
  }

  if (request.method === "POST") {
    const body = await request.json();
    await kv.set(["users", body.id], body);
    return Response.json({ success: true });
  }

  return new Response("Method not allowed", { status: 405 });
});
```

## AWS Lambda

### Basic Handler
```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const body = JSON.parse(event.body || '{}');

    // Process...

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ success: true }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal error' }),
    };
  }
};
```

### Med Powertools
```typescript
import { Logger } from '@aws-lambda-powertools/logger';
import { Tracer } from '@aws-lambda-powertools/tracer';
import { Metrics } from '@aws-lambda-powertools/metrics';

const logger = new Logger();
const tracer = new Tracer();
const metrics = new Metrics();

export const handler = async (event: any) => {
  logger.info('Processing request', { event });

  const segment = tracer.getSegment();
  const subsegment = segment?.addNewSubsegment('processData');

  try {
    // Process...
    metrics.addMetric('successfulRequests', 1);
    return { statusCode: 200 };
  } catch (error) {
    metrics.addMetric('failedRequests', 1);
    throw error;
  } finally {
    subsegment?.close();
  }
};
```

## Hono (Universal Edge Framework)

### Multi-platform
```typescript
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { cache } from 'hono/cache';

const app = new Hono();

// Middleware
app.use('*', cors());
app.use('*', logger());

// Cache för 1 timme
app.get('/api/data', cache({ cacheName: 'data', cacheControl: 'max-age=3600' }));

// Routes
app.get('/', (c) => c.text('Hello Hono!'));

app.get('/api/users/:id', async (c) => {
  const id = c.req.param('id');
  const user = await getUser(id);
  return c.json(user);
});

app.post('/api/users', async (c) => {
  const body = await c.req.json();
  const user = await createUser(body);
  return c.json(user, 201);
});

// Error handling
app.onError((err, c) => {
  console.error(err);
  return c.json({ error: 'Internal error' }, 500);
});

export default app;

// Fungerar på:
// - Cloudflare Workers
// - Vercel Edge
// - Deno Deploy
// - Bun
// - Node.js
```

## Edge Patterns

### Compute at Edge
```typescript
// Bildoptimering på edge
export default {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname.startsWith('/images/')) {
      const width = parseInt(url.searchParams.get('w') || '800');
      const format = url.searchParams.get('f') || 'webp';

      // Hämta och transformera bild
      const imageUrl = `https://origin.com${url.pathname}`;
      const response = await fetch(imageUrl, {
        cf: {
          image: {
            width,
            format,
            quality: 80,
          },
        },
      });

      return response;
    }

    return fetch(request);
  },
};
```

### Edge Authentication
```typescript
import { jwtVerify } from 'jose';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const authHeader = request.headers.get('Authorization');

    if (!authHeader?.startsWith('Bearer ')) {
      return new Response('Unauthorized', { status: 401 });
    }

    const token = authHeader.slice(7);

    try {
      const secret = new TextEncoder().encode(env.JWT_SECRET);
      const { payload } = await jwtVerify(token, secret);

      // Lägg till user info i request
      const modifiedRequest = new Request(request, {
        headers: new Headers(request.headers),
      });
      modifiedRequest.headers.set('X-User-Id', payload.sub as string);

      return fetch(modifiedRequest);
    } catch {
      return new Response('Invalid token', { status: 401 });
    }
  },
};
```

### Edge Caching
```typescript
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const cache = caches.default;
    const cacheKey = new Request(request.url, request);

    // Kolla cache först
    let response = await cache.match(cacheKey);

    if (!response) {
      // Hämta från origin
      response = await fetch(request);

      // Cacha response
      response = new Response(response.body, response);
      response.headers.set('Cache-Control', 'public, max-age=3600');

      ctx.waitUntil(cache.put(cacheKey, response.clone()));
    }

    return response;
  },
};
```

## Cold Start Optimization

### Minimal dependencies
```typescript
// ❌ Dåligt - stor bundle
import { everything } from 'huge-library';

// ✅ Bra - tree-shakeable import
import { specificFunction } from 'huge-library/specific';
```

### Lazy loading
```typescript
let heavyModule: typeof import('./heavy') | null = null;

async function getHeavyModule() {
  if (!heavyModule) {
    heavyModule = await import('./heavy');
  }
  return heavyModule;
}

export default {
  async fetch(request: Request): Promise<Response> {
    if (request.url.includes('/heavy-operation')) {
      const module = await getHeavyModule();
      return module.handle(request);
    }
    return new Response('OK');
  },
};
```

### Connection reuse
```typescript
// Återanvänd connections mellan requests
let dbConnection: Database | null = null;

function getDb(): Database {
  if (!dbConnection) {
    dbConnection = new Database(process.env.DB_URL);
  }
  return dbConnection;
}
```

## Testing Edge Functions

```typescript
import { unstable_dev } from 'wrangler';

describe('Worker', () => {
  let worker: Awaited<ReturnType<typeof unstable_dev>>;

  beforeAll(async () => {
    worker = await unstable_dev('src/index.ts', {
      experimental: { disableExperimentalWarning: true },
    });
  });

  afterAll(async () => {
    await worker.stop();
  });

  it('returns hello', async () => {
    const response = await worker.fetch('/');
    const text = await response.text();
    expect(text).toBe('Hello!');
  });
});
```

## Best Practices

1. **Minimal bundle** - Varje KB kostar vid cold start
2. **Stateless** - Ingen global state mellan requests
3. **Quick responses** - Edge har CPU/time limits
4. **Cache aggressivt** - Spara dyra operationer
5. **Graceful degradation** - Fallback vid fel
6. **Regional routing** - Håll data nära compute
7. **Streaming** - Börja svara innan allt är klart
