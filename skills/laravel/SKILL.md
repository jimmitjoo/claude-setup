---
name: Laravel Expert
description: Laravel best practices, Eloquent, middleware, queues, och modern PHP-utveckling med Pest för testning.
---

# Laravel Best Practices

## Projektstruktur

### Följ Laravel-konventioner
```
app/
├── Http/
│   ├── Controllers/      # Tunna controllers
│   ├── Middleware/
│   ├── Requests/         # Form Requests för validering
│   └── Resources/        # API Resources
├── Models/               # Eloquent models
├── Services/             # Business logic
├── Actions/              # Single-action klasser
└── Repositories/         # Data access (optional)
```

## Controllers

### Tunna controllers - flytta logik till Services/Actions
```php
// Bra - tunn controller
class UserController extends Controller
{
    public function store(StoreUserRequest $request, CreateUserAction $action)
    {
        $user = $action->execute($request->validated());

        return new UserResource($user);
    }
}

// Undvik - fet controller
class UserController extends Controller
{
    public function store(Request $request)
    {
        // 50+ rader av validering och logik...
    }
}
```

### Resource Controllers
```php
// routes/api.php
Route::apiResource('users', UserController::class);

// Genererar: index, store, show, update, destroy
```

## Validering

### Form Requests
```php
class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // eller policy-check
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users'],
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'password' => ['required', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'Denna e-post är redan registrerad.',
        ];
    }
}
```

## Eloquent

### Relationships
```php
class User extends Model
{
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class);
    }
}
```

### Scopes för återanvändbar query-logik
```php
class Post extends Model
{
    public function scopePublished(Builder $query): Builder
    {
        return $query->whereNotNull('published_at')
                     ->where('published_at', '<=', now());
    }

    public function scopeByAuthor(Builder $query, User $user): Builder
    {
        return $query->where('user_id', $user->id);
    }
}

// Användning
Post::published()->byAuthor($user)->get();
```

### Undvik N+1 med Eager Loading
```php
// Dåligt - N+1
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name; // Query per post
}

// Bra - Eager loading
$posts = Post::with('author')->get();
```

### Mass Assignment
```php
class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];

    // ELLER blocka specifika
    protected $guarded = ['id', 'is_admin'];
}
```

## API Resources

```php
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'posts' => PostResource::collection($this->whenLoaded('posts')),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

## Queues & Jobs

```php
class ProcessPodcast implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public Podcast $podcast
    ) {}

    public function handle(AudioProcessor $processor): void
    {
        $processor->process($this->podcast);
    }

    public function failed(Throwable $exception): void
    {
        // Notifiera om misslyckande
    }
}

// Dispatch
ProcessPodcast::dispatch($podcast);
ProcessPodcast::dispatch($podcast)->delay(now()->addMinutes(10));
```

## Middleware

```php
class EnsureUserIsSubscribed
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user()?->subscribed()) {
            return redirect('subscribe');
        }

        return $next($request);
    }
}
```

## Testing med Pest

### Setup
```bash
composer require pestphp/pest --dev
composer require pestphp/pest-plugin-laravel --dev
./vendor/bin/pest --init
```

### Feature Tests
```php
// tests/Feature/UserTest.php
use App\Models\User;

it('can create a user', function () {
    $response = $this->postJson('/api/users', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'password',
        'password_confirmation' => 'password',
    ]);

    $response->assertStatus(201)
             ->assertJsonPath('data.email', 'test@example.com');

    $this->assertDatabaseHas('users', [
        'email' => 'test@example.com',
    ]);
});

it('requires valid email', function () {
    $response = $this->postJson('/api/users', [
        'name' => 'Test',
        'email' => 'not-an-email',
        'password' => 'password',
    ]);

    $response->assertStatus(422)
             ->assertJsonValidationErrors(['email']);
});

it('returns 404 for non-existent user', function () {
    $this->getJson('/api/users/non-existent-id')
         ->assertNotFound();
});
```

### Unit Tests
```php
// tests/Unit/UserServiceTest.php
use App\Services\UserService;

beforeEach(function () {
    $this->service = app(UserService::class);
});

it('hashes password when creating user', function () {
    $user = $this->service->create([
        'name' => 'Test',
        'email' => 'test@example.com',
        'password' => 'plain-password',
    ]);

    expect($user->password)->not->toBe('plain-password');
    expect(Hash::check('plain-password', $user->password))->toBeTrue();
});

it('throws exception for duplicate email', function () {
    User::factory()->create(['email' => 'test@example.com']);

    $this->service->create([
        'name' => 'Test',
        'email' => 'test@example.com',
        'password' => 'password',
    ]);
})->throws(DuplicateEmailException::class);
```

### Datasets för parametriserade tester
```php
it('validates email format', function (string $email, bool $valid) {
    $response = $this->postJson('/api/users', [
        'name' => 'Test',
        'email' => $email,
        'password' => 'password',
    ]);

    if ($valid) {
        $response->assertStatus(201);
    } else {
        $response->assertStatus(422);
    }
})->with([
    ['valid@example.com', true],
    ['also.valid@domain.org', true],
    ['invalid', false],
    ['@nodomain.com', false],
    ['spaces in@email.com', false],
]);
```

### Expectations (assertions)
```php
it('returns user with correct structure', function () {
    $user = User::factory()->create();

    $response = $this->getJson("/api/users/{$user->id}");

    expect($response->json('data'))
        ->toHaveKey('id')
        ->toHaveKey('name')
        ->toHaveKey('email')
        ->not->toHaveKey('password');
});

it('lists users with pagination', function () {
    User::factory()->count(25)->create();

    $response = $this->getJson('/api/users');

    expect($response->json())
        ->data->toHaveCount(15)
        ->meta->toHaveKey('total')
        ->meta->total->toBe(25);
});
```

### Mocking
```php
use App\Services\PaymentGateway;

it('processes payment successfully', function () {
    $mock = $this->mock(PaymentGateway::class);
    $mock->shouldReceive('charge')
         ->once()
         ->with(1000, 'tok_visa')
         ->andReturn(true);

    $response = $this->postJson('/api/payments', [
        'amount' => 1000,
        'token' => 'tok_visa',
    ]);

    $response->assertOk();
});
```

## Säkerhet

- Använd `$fillable` eller `$guarded` på alla models
- Validera ALL input via Form Requests
- Använd Policies för auktorisering
- Sanitera output med `{{ }}` (inte `{!! !!}`)
- Rate limiting på API:er
- CSRF-skydd på web routes
