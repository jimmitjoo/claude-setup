---
name: Event-Driven & Realtime Expert
description: Kafka, pub/sub, WebSockets, CQRS, event sourcing, och realtidsapplikationer.
---

# Event-Driven & Realtime Best Practices

## Event-Driven Architecture

### Varför Events?
```
Request/Response:     A → B → C → D (synkront, tight coupling)
Event-Driven:         A → Event Bus ← B, C, D (asynkront, loose coupling)

Fördelar:
- Lös koppling mellan tjänster
- Skalbarhet (lägg till consumers)
- Resiliens (retry, dead letter queues)
- Audit trail (events är historik)
```

### Event Design
```typescript
// Bra event - beskriver VAD som hände
interface OrderPlaced {
  type: 'OrderPlaced';
  timestamp: string;
  data: {
    orderId: string;
    customerId: string;
    items: Array<{ productId: string; quantity: number }>;
    totalAmount: number;
  };
  metadata: {
    correlationId: string;
    causationId: string;
    userId: string;
  };
}

// Dåligt event - beskriver kommando
interface CreateOrder {  // ❌ Imperativ
  type: 'CreateOrder';
  // ...
}
```

## Apache Kafka

### Producer
```typescript
import { Kafka, Partitioners } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: ['kafka1:9092', 'kafka2:9092'],
});

const producer = kafka.producer({
  createPartitioner: Partitioners.DefaultPartitioner,
});

await producer.connect();

// Skicka event
await producer.send({
  topic: 'orders',
  messages: [
    {
      key: order.id,  // Samma key = samma partition = ordning garanterad
      value: JSON.stringify({
        type: 'OrderPlaced',
        data: order,
        timestamp: new Date().toISOString(),
      }),
      headers: {
        'correlation-id': correlationId,
      },
    },
  ],
});

// Batch för throughput
await producer.sendBatch({
  topicMessages: [
    {
      topic: 'orders',
      messages: orders.map(o => ({ key: o.id, value: JSON.stringify(o) })),
    },
  ],
});
```

### Consumer
```typescript
const consumer = kafka.consumer({ groupId: 'order-processor' });

await consumer.connect();
await consumer.subscribe({ topic: 'orders', fromBeginning: false });

await consumer.run({
  eachMessage: async ({ topic, partition, message }) => {
    const event = JSON.parse(message.value!.toString());

    try {
      await processEvent(event);
      // Auto-commit efter lyckad processing
    } catch (error) {
      // Hantera fel - kanske skicka till DLQ
      await sendToDeadLetterQueue(event, error);
    }
  },
});

// Eller batch processing för throughput
await consumer.run({
  eachBatch: async ({ batch, resolveOffset, heartbeat }) => {
    for (const message of batch.messages) {
      await processEvent(JSON.parse(message.value!.toString()));
      resolveOffset(message.offset);
      await heartbeat();
    }
  },
});
```

### Consumer Groups
```
Topic: orders (3 partitions)

Consumer Group: order-processors
├── Consumer 1 → Partition 0
├── Consumer 2 → Partition 1
└── Consumer 3 → Partition 2

Lägg till Consumer 4 → Rebalance, en får ingen partition
Ta bort Consumer 2 → Consumer 1 eller 3 tar över Partition 1
```

## Redis Pub/Sub & Streams

### Pub/Sub (fire-and-forget)
```typescript
import Redis from 'ioredis';

const publisher = new Redis();
const subscriber = new Redis();

// Subscribe
subscriber.subscribe('notifications', (err, count) => {
  console.log(`Subscribed to ${count} channels`);
});

subscriber.on('message', (channel, message) => {
  const data = JSON.parse(message);
  console.log(`Received on ${channel}:`, data);
});

// Publish
await publisher.publish('notifications', JSON.stringify({
  type: 'NEW_MESSAGE',
  userId: '123',
  content: 'Hello!',
}));
```

### Streams (persistent, consumer groups)
```typescript
// Producent
await redis.xadd('orders', '*',
  'type', 'OrderPlaced',
  'orderId', '123',
  'amount', '99.99',
);

// Skapa consumer group
await redis.xgroup('CREATE', 'orders', 'processors', '0', 'MKSTREAM');

// Konsument
const messages = await redis.xreadgroup(
  'GROUP', 'processors', 'consumer-1',
  'COUNT', 10,
  'BLOCK', 5000,
  'STREAMS', 'orders', '>',
);

for (const [stream, entries] of messages || []) {
  for (const [id, fields] of entries) {
    await processOrder(Object.fromEntries(fields));
    await redis.xack('orders', 'processors', id);
  }
}
```

## WebSockets

### Server (Node.js + ws)
```typescript
import { WebSocketServer, WebSocket } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

// Håll koll på connections
const clients = new Map<string, WebSocket>();

wss.on('connection', (ws, request) => {
  const userId = getUserIdFromRequest(request);
  clients.set(userId, ws);

  ws.on('message', async (data) => {
    const message = JSON.parse(data.toString());

    switch (message.type) {
      case 'CHAT_MESSAGE':
        await handleChatMessage(message, userId);
        break;
      case 'TYPING':
        broadcastToRoom(message.roomId, {
          type: 'USER_TYPING',
          userId,
        });
        break;
    }
  });

  ws.on('close', () => {
    clients.delete(userId);
  });

  // Heartbeat
  ws.on('pong', () => {
    (ws as any).isAlive = true;
  });
});

// Ping/pong för att upptäcka döda connections
setInterval(() => {
  wss.clients.forEach((ws) => {
    if ((ws as any).isAlive === false) {
      return ws.terminate();
    }
    (ws as any).isAlive = false;
    ws.ping();
  });
}, 30000);

function broadcastToRoom(roomId: string, message: object) {
  const roomMembers = getRoomMembers(roomId);
  for (const userId of roomMembers) {
    const ws = clients.get(userId);
    if (ws?.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }
}
```

### Client
```typescript
class WebSocketClient {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private listeners = new Map<string, Set<Function>>();

  connect(url: string) {
    this.ws = new WebSocket(url);

    this.ws.onopen = () => {
      this.reconnectAttempts = 0;
      this.emit('connected', null);
    };

    this.ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.emit(message.type, message);
    };

    this.ws.onclose = () => {
      this.emit('disconnected', null);
      this.reconnect(url);
    };

    this.ws.onerror = (error) => {
      this.emit('error', error);
    };
  }

  private reconnect(url: string) {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      return;
    }

    const delay = Math.min(1000 * 2 ** this.reconnectAttempts, 30000);
    this.reconnectAttempts++;

    setTimeout(() => this.connect(url), delay);
  }

  send(type: string, data: object) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, ...data }));
    }
  }

  on(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(callback);
  }

  private emit(event: string, data: any) {
    this.listeners.get(event)?.forEach(cb => cb(data));
  }
}
```

## Server-Sent Events (SSE)

### Server
```typescript
import express from 'express';

const app = express();
const clients = new Set<express.Response>();

app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  clients.add(res);

  req.on('close', () => {
    clients.delete(res);
  });
});

// Skicka event till alla clients
function broadcast(event: string, data: object) {
  const message = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  clients.forEach(client => client.write(message));
}

// Användning
broadcast('notification', { message: 'New order received!' });
```

### Client
```typescript
const eventSource = new EventSource('/events');

eventSource.addEventListener('notification', (event) => {
  const data = JSON.parse(event.data);
  showNotification(data.message);
});

eventSource.onerror = () => {
  // Auto-reconnect är inbyggt i EventSource
  console.log('Connection lost, reconnecting...');
};
```

## CQRS (Command Query Responsibility Segregation)

```typescript
// Commands - skriver till write model
interface CreateOrderCommand {
  type: 'CreateOrder';
  customerId: string;
  items: OrderItem[];
}

class OrderCommandHandler {
  async handle(command: CreateOrderCommand) {
    // Validera
    const customer = await this.customerRepo.find(command.customerId);
    if (!customer) throw new Error('Customer not found');

    // Skapa aggregat
    const order = Order.create(command);

    // Spara
    await this.orderRepo.save(order);

    // Publicera events
    await this.eventBus.publish(order.domainEvents);
  }
}

// Queries - läser från read model (optimerat för läsning)
class OrderQueryHandler {
  async getOrderSummary(orderId: string): Promise<OrderSummaryDTO> {
    // Läs från denormaliserad read model
    return this.readDb.query(`
      SELECT o.*, c.name as customer_name, ...
      FROM order_summaries o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.id = $1
    `, [orderId]);
  }
}

// Event handler uppdaterar read model
class OrderProjection {
  async on(event: OrderPlaced) {
    await this.readDb.query(`
      INSERT INTO order_summaries (id, customer_id, total, status, ...)
      VALUES ($1, $2, $3, 'placed', ...)
    `, [event.data.orderId, event.data.customerId, event.data.total]);
  }
}
```

## Event Sourcing

```typescript
// Events är källan till sanning
interface Event {
  id: string;
  aggregateId: string;
  type: string;
  data: object;
  timestamp: Date;
  version: number;
}

class Order {
  private events: Event[] = [];
  private state: OrderState = { status: 'draft', items: [] };

  // Bygg state från events
  static fromEvents(events: Event[]): Order {
    const order = new Order();
    for (const event of events) {
      order.apply(event);
    }
    return order;
  }

  // Applicera event på state
  private apply(event: Event) {
    switch (event.type) {
      case 'OrderCreated':
        this.state = { ...this.state, ...event.data, status: 'created' };
        break;
      case 'ItemAdded':
        this.state.items.push(event.data as OrderItem);
        break;
      case 'OrderPlaced':
        this.state.status = 'placed';
        break;
    }
    this.events.push(event);
  }

  // Kommando skapar event
  addItem(item: OrderItem) {
    if (this.state.status !== 'created') {
      throw new Error('Cannot add items to placed order');
    }
    this.apply({
      id: uuid(),
      aggregateId: this.state.id,
      type: 'ItemAdded',
      data: item,
      timestamp: new Date(),
      version: this.events.length + 1,
    });
  }

  getUncommittedEvents(): Event[] {
    return this.events.filter(e => !e.committed);
  }
}

// Event Store
class EventStore {
  async save(aggregateId: string, events: Event[], expectedVersion: number) {
    // Optimistic concurrency
    const currentVersion = await this.getCurrentVersion(aggregateId);
    if (currentVersion !== expectedVersion) {
      throw new ConcurrencyError();
    }

    await this.db.transaction(async (tx) => {
      for (const event of events) {
        await tx.query(`
          INSERT INTO events (id, aggregate_id, type, data, version, timestamp)
          VALUES ($1, $2, $3, $4, $5, $6)
        `, [event.id, aggregateId, event.type, event.data, event.version, event.timestamp]);
      }
    });

    // Publicera till event bus
    for (const event of events) {
      await this.eventBus.publish(event);
    }
  }

  async getEvents(aggregateId: string): Promise<Event[]> {
    return this.db.query(`
      SELECT * FROM events
      WHERE aggregate_id = $1
      ORDER BY version ASC
    `, [aggregateId]);
  }
}
```

## Scaling Patterns

### Partitioning
```typescript
// Partitionera baserat på key för att bevara ordning
function getPartition(key: string, numPartitions: number): number {
  const hash = crypto.createHash('md5').update(key).digest('hex');
  return parseInt(hash.slice(0, 8), 16) % numPartitions;
}

// Alla events för samma order hamnar i samma partition
const partition = getPartition(order.id, 10);
```

### Dead Letter Queue
```typescript
async function processWithRetry(event: Event, maxRetries = 3) {
  let attempts = 0;

  while (attempts < maxRetries) {
    try {
      await processEvent(event);
      return;
    } catch (error) {
      attempts++;
      await sleep(1000 * 2 ** attempts);  // Exponential backoff
    }
  }

  // Ge upp - skicka till DLQ
  await sendToDeadLetterQueue(event, error);
}
```

### Idempotency
```typescript
async function processEventIdempotently(event: Event) {
  // Kolla om redan processad
  const processed = await redis.get(`processed:${event.id}`);
  if (processed) {
    return; // Already processed
  }

  // Processa
  await processEvent(event);

  // Markera som processad (med TTL)
  await redis.set(`processed:${event.id}`, '1', 'EX', 86400);
}
```

## Best Practices

1. **Events är immutable** - Ändra aldrig publicerade events
2. **Versionera events** - För backwards compatibility
3. **Idempotent consumers** - Hantera duplicates
4. **Correlation IDs** - Spåra genom hela flödet
5. **Dead Letter Queues** - Hantera failures
6. **Monitoring** - Lag, throughput, errors
7. **Schema registry** - Validera event format
8. **Replay capability** - Kunna bygga om state
