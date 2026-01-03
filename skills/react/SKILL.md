---
name: React Expert
description: Moderna React-mönster med hooks, Server Components, och best practices för 2024+.
---

# React Best Practices

## Komponenter

### Funktionella komponenter med TypeScript
```tsx
interface UserCardProps {
  user: User;
  onSelect?: (user: User) => void;
}

export function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div onClick={() => onSelect?.(user)}>
      {user.name}
    </div>
  );
}
```

### Undvik props drilling - använd composition
```tsx
// Bra - composition
function Layout({ children }: { children: React.ReactNode }) {
  return <main>{children}</main>;
}

// Undvik - props drilling
function Layout({ user, theme, settings, ...props }) {
  return <Main user={user} theme={theme} settings={settings} {...props} />;
}
```

## Hooks

### useState - enkla värden
```tsx
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);
```

### useReducer - komplex state logik
```tsx
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'set'; value: number };

function reducer(state: number, action: Action): number {
  switch (action.type) {
    case 'increment': return state + 1;
    case 'decrement': return state - 1;
    case 'set': return action.value;
  }
}
```

### useMemo/useCallback - endast vid behov
```tsx
// Använd när:
// 1. Dyra beräkningar
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// 2. Referentiell stabilitet för child components
const handleClick = useCallback(() => {
  onSelect(item);
}, [item, onSelect]);

// UNDVIK prematur optimering - börja utan memo
```

### Custom hooks för återanvändbar logik
```tsx
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

## Data Fetching

### React Query / TanStack Query
```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  return <Profile user={data} />;
}
```

## Server Components (Next.js 13+)

### Default till Server Components
```tsx
// app/users/page.tsx - Server Component
async function UsersPage() {
  const users = await db.users.findMany();
  return <UserList users={users} />;
}
```

### "use client" endast när nödvändigt
```tsx
'use client';

// Behövs för: useState, useEffect, event handlers, browser APIs
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## Undvik

- Inline object/array i props (skapar nya referenser)
- useEffect för derived state (använd useMemo)
- Index som key i listor (använd stabila IDs)
- Direkt DOM-manipulation (använd refs)
- Prop drilling > 2-3 nivåer (använd context eller composition)
