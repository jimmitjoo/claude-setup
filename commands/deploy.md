---
argument-hint: "miljö (staging/prod)"
---

Använd devops-agenten för att förbereda och genomföra deployment.

**VIKTIGT: Nämn ALDRIG Claude, Claude Code, AI, eller liknande i commits eller dokumentation.**

## Pre-deployment Checklist

### Kod
- [ ] Alla tester passerar
- [ ] Linting OK
- [ ] Build lyckas
- [ ] Inga TODO/FIXME för denna release

### Review
- [ ] Code review godkänd
- [ ] Säkerhetsgranskning (om tillämpligt)
- [ ] Breaking changes dokumenterade

### Environment
- [ ] Environment variables konfigurerade
- [ ] Secrets uppdaterade
- [ ] Databasmigrationer förberedda

### Rollback
- [ ] Rollback-plan dokumenterad
- [ ] Tidigare version identifierad
- [ ] Rollback testad (om möjligt)

## Deployment Steps

### 1. Pre-deploy
```bash
# Verifiera branch
git status

# Kör tester
npm test

# Bygg
npm run build
```

### 2. Deploy
```bash
# Beroende på setup:
# - git push (om CI/CD)
# - docker push + kubectl apply
# - serverless deploy
# - etc
```

### 3. Post-deploy
```bash
# Smoke test
curl https://app.example.com/health

# Verifiera kritiska flöden
# Monitorera loggar och metrics
```

## Rollback

```bash
# Vid problem:
# 1. Identifiera problemet
# 2. Besluta: fix forward eller rollback?
# 3. Om rollback: återställ till senaste stabila

# Exempel:
git revert HEAD
# eller
kubectl rollout undo deployment/app
```

Om $ARGUMENTS anges, förbered deployment till den miljön.
Annars, visa deployment status och föreslå nästa steg.
