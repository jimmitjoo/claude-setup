---
name: Go Expert
description: Idiomatic Go, concurrency patterns, error handling, och projektstruktur.
---

# Go Best Practices

## Projektstruktur

### Standard Layout
```
myproject/
├── cmd/
│   └── myapp/
│       └── main.go         # Entry point
├── internal/               # Privat kod
│   ├── handler/            # HTTP handlers
│   ├── service/            # Business logic
│   ├── repository/         # Data access
│   └── model/              # Domain types
├── pkg/                    # Publikt API (om library)
├── api/                    # OpenAPI specs, proto files
├── go.mod
└── go.sum
```

## Namngivning

### Idiomatisk Go
```go
// Korta, koncisa namn
var buf bytes.Buffer           // inte buffer
for i, v := range items {}     // inte index, value
func (s *Server) ServeHTTP()   // receiver = första bokstaven

// Exporterade namn börjar med versal
type User struct {}            // Exporterad
type userRepo struct {}        // Privat

// Interfaces namnges med -er suffix
type Reader interface { Read(p []byte) (n int, err error) }
type Stringer interface { String() string }

// Undvik Get-prefix
func (u *User) Name() string   // Bra
func (u *User) GetName() string // Undvik
```

## Error Handling

### Returnera errors, panika inte
```go
func ReadFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, fmt.Errorf("open file %s: %w", path, err)
    }
    defer f.Close()

    return io.ReadAll(f)
}
```

### Custom errors
```go
var (
    ErrNotFound = errors.New("not found")
    ErrInvalid  = errors.New("invalid input")
)

type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// Kolla error-typ
if errors.Is(err, ErrNotFound) { ... }

var valErr *ValidationError
if errors.As(err, &valErr) { ... }
```

### Wrappa errors med context
```go
if err != nil {
    return fmt.Errorf("create user %s: %w", email, err)
}
```

## Concurrency

### Goroutines och channels
```go
func process(items []Item) []Result {
    results := make(chan Result, len(items))

    var wg sync.WaitGroup
    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            results <- processItem(item)
        }(item)
    }

    go func() {
        wg.Wait()
        close(results)
    }()

    var out []Result
    for r := range results {
        out = append(out, r)
    }
    return out
}
```

### Context för cancellation och timeouts
```go
func FetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}

// Användning
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

data, err := FetchData(ctx, "https://api.example.com")
```

### Worker pool
```go
func worker(id int, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        results <- process(job)
    }
}

func main() {
    jobs := make(chan Job, 100)
    results := make(chan Result, 100)

    // Starta workers
    for w := 0; w < 5; w++ {
        go worker(w, jobs, results)
    }

    // Skicka jobb
    for _, job := range allJobs {
        jobs <- job
    }
    close(jobs)
}
```

## HTTP Server

### Chi router (rekommenderad)
```go
func main() {
    r := chi.NewRouter()

    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(60 * time.Second))

    r.Route("/api/v1", func(r chi.Router) {
        r.Route("/users", func(r chi.Router) {
            r.Get("/", listUsers)
            r.Post("/", createUser)
            r.Get("/{id}", getUser)
        })
    })

    http.ListenAndServe(":8080", r)
}

func getUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")

    user, err := userService.Get(r.Context(), id)
    if err != nil {
        http.Error(w, err.Error(), http.StatusNotFound)
        return
    }

    json.NewEncoder(w).Encode(user)
}
```

## Testing

### Table-driven tests
```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        wantErr bool
    }{
        {
            name:    "valid user",
            input:   CreateUserInput{Email: "test@example.com"},
            wantErr: false,
        },
        {
            name:    "invalid email",
            input:   CreateUserInput{Email: "invalid"},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := CreateUser(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("CreateUser() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### Testify för assertions
```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestUser(t *testing.T) {
    user, err := CreateUser(input)

    require.NoError(t, err)  // Stoppar om fel
    assert.Equal(t, "test@example.com", user.Email)
    assert.NotEmpty(t, user.ID)
}
```

### HTTP testing
```go
func TestGetUser(t *testing.T) {
    // Setup
    r := setupRouter()
    user := createTestUser(t)

    // Request
    req := httptest.NewRequest("GET", "/users/"+user.ID, nil)
    w := httptest.NewRecorder()
    r.ServeHTTP(w, req)

    // Assert
    assert.Equal(t, 200, w.Code)

    var response User
    json.Unmarshal(w.Body.Bytes(), &response)
    assert.Equal(t, user.Email, response.Email)
}
```

## Undvik

- `init()` funktioner - explicit är bättre
- Globala variabler - dependency injection
- Naked returns i långa funktioner
- Panic för expected errors
- Interface pollution - acceptera interfaces, returnera structs
