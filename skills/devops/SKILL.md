---
name: DevOps Expert
description: Docker, CI/CD, GitHub Actions, deployment, monitoring och infrastructure.
---

# DevOps Best Practices

## Hosting (EU-fokus)
- **Hetzner** - Prisvärt, tyskt, bra för VPS
- **Scaleway** - Franskt, bra object storage
- **GleSYS** - Svenskt, GDPR-säkert
- **Cloudflare** - Edge, Workers, R2 (gratis tier generös)

### Undvik
- AWS (dyrt, vendor lock-in, komplext)
- Vercel Pro vid skala (dyrt)
- US-baserade moln för känslig data

## Docker

### Multi-stage Dockerfile
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
USER nextjs
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Docker Compose
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://db:5432/app
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 5s
      timeout: 5s
      retries: 5
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

### .dockerignore
```
node_modules
.git
*.md
.env*
.DS_Store
coverage
dist
.next
```

## GitHub Actions

### CI Pipeline
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: |
          # Deploy commands
```

### Cache strategies
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Secrets
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## Environment Variables

### Struktur
```bash
# .env.example (i git)
DATABASE_URL=postgres://localhost:5432/app
REDIS_URL=redis://localhost:6379
API_KEY=

# .env.local (ignorerad)
DATABASE_URL=postgres://actual:creds@host:5432/db
API_KEY=actual-key
```

### Validering
```typescript
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(['development', 'production', 'test']),
});

export const env = envSchema.parse(process.env);
```

## Monitoring

### Health checks
```typescript
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

app.get('/ready', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.json({ status: 'ready' });
  } catch {
    res.status(503).json({ status: 'not ready' });
  }
});
```

### Structured logging
```typescript
logger.info('Request processed', {
  method: req.method,
  path: req.path,
  duration: Date.now() - start,
  status: res.statusCode,
});
```

## Deployment Strategies

### Rolling (default)
- Gradvis ersättning
- Zero downtime
- Automatisk rollback

### Blue-Green
- Två identiska miljöer
- Instant switch
- Snabb rollback

### Canary
- Liten % får ny version
- Monitorera
- Gradvis öka

## Självhostad PaaS

### Coolify (rekommenderas)
```bash
# Installera på VPS (Hetzner, GleSYS, etc.)
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```
- Vercel/Netlify-liknande UX
- Git push deploy
- Automatiska SSL-certifikat
- Databashantering

### Dokku
```bash
# Minimal Heroku-klon
wget https://dokku.com/install/v0.32.3/bootstrap.sh
sudo bash bootstrap.sh
```

## Security

### Container
- Non-root user
- Minimal base image
- Inga secrets i image
- Scan för vulnerabilities

### Secrets
- Aldrig i kod/git
- Använd: Infisical, Doppler, eller self-hosted Vault
- Rotera regelbundet
- Audit access
