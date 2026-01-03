---
name: Rust Expert
description: Idiomatic Rust, ownership, error handling, async, och säker systemutveckling.
---

# Rust Best Practices

## Projektstruktur

### Cargo workspace för större projekt
```
myproject/
├── Cargo.toml              # Workspace root
├── crates/
│   ├── myapp/              # Binary crate
│   │   ├── Cargo.toml
│   │   └── src/
│   │       └── main.rs
│   ├── mylib/              # Library crate
│   │   ├── Cargo.toml
│   │   └── src/
│   │       └── lib.rs
│   └── common/             # Shared types
└── tests/                  # Integration tests
```

### Modulstruktur
```rust
// src/lib.rs
mod user;
mod post;

pub use user::User;
pub use post::Post;

// src/user/mod.rs
mod model;
mod repository;
mod service;

pub use model::User;
pub use service::UserService;
```

## Ownership & Borrowing

### Grundregler
```rust
// Ownership - värdet flyttas
let s1 = String::from("hello");
let s2 = s1;  // s1 är nu ogiltig

// Borrowing - referens utan ägande
fn print_len(s: &String) {
    println!("{}", s.len());
}

// Mutable borrow - endast en åt gången
fn append(s: &mut String) {
    s.push_str(" world");
}
```

### Clone vs Copy
```rust
// Copy - för små, stack-allokerade typer
let x = 5;
let y = x;  // x är fortfarande giltig (Copy)

// Clone - explicit för heap-data
let s1 = String::from("hello");
let s2 = s1.clone();  // Båda giltiga

// Implementera Copy för enkla structs
#[derive(Clone, Copy)]
struct Point { x: i32, y: i32 }
```

## Error Handling

### Result och Option
```rust
fn find_user(id: &str) -> Result<User, UserError> {
    let user = db.find(id).ok_or(UserError::NotFound)?;
    Ok(user)
}

fn get_username(user: Option<&User>) -> &str {
    user.map(|u| u.name.as_str()).unwrap_or("Anonymous")
}
```

### Custom errors med thiserror
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("User not found: {0}")]
    NotFound(String),

    #[error("Invalid email format")]
    InvalidEmail,

    #[error("Database error")]
    Database(#[from] sqlx::Error),
}
```

### anyhow för applikationskod
```rust
use anyhow::{Context, Result};

fn load_config() -> Result<Config> {
    let content = fs::read_to_string("config.toml")
        .context("Failed to read config file")?;

    let config: Config = toml::from_str(&content)
        .context("Failed to parse config")?;

    Ok(config)
}
```

## Patterns

### Builder pattern
```rust
#[derive(Default)]
pub struct RequestBuilder {
    url: String,
    method: Method,
    headers: HashMap<String, String>,
}

impl RequestBuilder {
    pub fn new(url: impl Into<String>) -> Self {
        Self {
            url: url.into(),
            ..Default::default()
        }
    }

    pub fn method(mut self, method: Method) -> Self {
        self.method = method;
        self
    }

    pub fn header(mut self, key: &str, value: &str) -> Self {
        self.headers.insert(key.to_string(), value.to_string());
        self
    }

    pub fn build(self) -> Request {
        Request { /* ... */ }
    }
}

// Användning
let req = RequestBuilder::new("https://api.example.com")
    .method(Method::POST)
    .header("Content-Type", "application/json")
    .build();
```

### Newtype pattern
```rust
pub struct UserId(String);
pub struct Email(String);

impl Email {
    pub fn new(email: &str) -> Result<Self, ValidationError> {
        if email.contains('@') {
            Ok(Self(email.to_string()))
        } else {
            Err(ValidationError::InvalidEmail)
        }
    }
}
```

## Async/Await

### Tokio runtime
```rust
#[tokio::main]
async fn main() -> Result<()> {
    let server = Server::bind(&"0.0.0.0:8080".parse()?);
    server.serve(app()).await?;
    Ok(())
}
```

### Concurrent operations
```rust
use tokio::join;

async fn fetch_all() -> Result<(User, Posts)> {
    let (user, posts) = join!(
        fetch_user(),
        fetch_posts()
    );
    Ok((user?, posts?))
}

// Eller med futures
use futures::future::try_join_all;

let results = try_join_all(urls.iter().map(fetch_url)).await?;
```

## Axum Web Framework

```rust
use axum::{
    extract::{Path, State},
    routing::{get, post},
    Json, Router,
};

async fn get_user(
    State(db): State<Database>,
    Path(id): Path<String>,
) -> Result<Json<User>, AppError> {
    let user = db.find_user(&id).await?;
    Ok(Json(user))
}

async fn create_user(
    State(db): State<Database>,
    Json(input): Json<CreateUserInput>,
) -> Result<Json<User>, AppError> {
    let user = db.create_user(input).await?;
    Ok(Json(user))
}

fn app(db: Database) -> Router {
    Router::new()
        .route("/users", post(create_user))
        .route("/users/:id", get(get_user))
        .with_state(db)
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_email_validation() {
        assert!(Email::new("valid@example.com").is_ok());
        assert!(Email::new("invalid").is_err());
    }

    #[tokio::test]
    async fn test_fetch_user() {
        let db = setup_test_db().await;
        let user = create_test_user(&db).await;

        let result = fetch_user(&db, &user.id).await;
        assert!(result.is_ok());
    }
}
```

### Integration tests
```rust
// tests/api_test.rs
use axum_test::TestServer;

#[tokio::test]
async fn test_create_user() {
    let app = create_test_app().await;
    let server = TestServer::new(app).unwrap();

    let response = server
        .post("/users")
        .json(&json!({
            "email": "test@example.com",
            "name": "Test User"
        }))
        .await;

    response.assert_status_ok();
    response.assert_json_contains(&json!({
        "email": "test@example.com"
    }));
}
```

## Undvik

- `unwrap()` i produktionskod - använd `?` eller hantera errors
- `clone()` i onödan - använd references
- `String` när `&str` räcker
- `Box<dyn Trait>` när generics fungerar
- Mutable state där immutable fungerar
- `unsafe` utan dokumenterad anledning
