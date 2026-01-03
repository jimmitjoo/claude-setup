---
name: Python Expert
description: Modern Python, type hints, async, FastAPI, och best practices för scripting och backend.
---

# Python Best Practices

## Projektstruktur

```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── main.py
│       ├── api/
│       │   ├── __init__.py
│       │   └── routes.py
│       ├── core/
│       │   ├── __init__.py
│       │   ├── config.py
│       │   └── security.py
│       ├── models/
│       │   └── __init__.py
│       └── services/
│           └── __init__.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── pyproject.toml
├── requirements.txt
└── README.md
```

## Type Hints

### Grundläggande
```python
def greet(name: str) -> str:
    return f"Hello, {name}"

def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

def find_user(user_id: int) -> User | None:
    return db.get(user_id)
```

### Avancerade typer
```python
from typing import TypeVar, Generic, Callable
from collections.abc import Sequence

T = TypeVar('T')

class Repository(Generic[T]):
    def find(self, id: int) -> T | None: ...
    def find_all(self) -> list[T]: ...

# Callable
Handler = Callable[[Request], Response]

# Union och Optional
def parse(value: str | int) -> str: ...
def get_name(user: User | None = None) -> str: ...
```

### Pydantic Models
```python
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=2, max_length=100)
    age: int | None = Field(default=None, ge=0, le=150)

class User(UserCreate):
    id: int

    class Config:
        from_attributes = True  # Från ORM objects
```

## FastAPI

### Basic Setup
```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    name: str
    price: float

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def get_item(item_id: int):
    item = await db.get_item(item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@app.post("/items", status_code=201)
async def create_item(item: Item):
    return await db.create_item(item)
```

### Dependency Injection
```python
from fastapi import Depends

async def get_db():
    db = Database()
    try:
        yield db
    finally:
        await db.close()

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Database = Depends(get_db)
) -> User:
    user = await db.get_user_by_token(token)
    if not user:
        raise HTTPException(status_code=401)
    return user

@app.get("/me")
async def get_me(user: User = Depends(get_current_user)):
    return user
```

### Router Organization
```python
# api/users.py
from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/")
async def list_users(): ...

@router.get("/{user_id}")
async def get_user(user_id: int): ...

# main.py
from api import users
app.include_router(users.router)
```

## Async/Await

```python
import asyncio
import httpx

async def fetch_url(url: str) -> str:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.text

async def fetch_all(urls: list[str]) -> list[str]:
    tasks = [fetch_url(url) for url in urls]
    return await asyncio.gather(*tasks)

# Köra async kod
async def main():
    results = await fetch_all(["http://example.com", "http://example.org"])
    print(results)

asyncio.run(main())
```

## Error Handling

```python
# Custom exceptions
class NotFoundError(Exception):
    def __init__(self, resource: str, id: int):
        self.resource = resource
        self.id = id
        super().__init__(f"{resource} with id {id} not found")

class ValidationError(Exception):
    def __init__(self, errors: list[str]):
        self.errors = errors
        super().__init__(f"Validation failed: {errors}")

# Användning
def get_user(user_id: int) -> User:
    user = db.get(user_id)
    if not user:
        raise NotFoundError("User", user_id)
    return user

# Context manager för cleanup
from contextlib import contextmanager

@contextmanager
def database_transaction():
    conn = db.connect()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
```

## Testing med Pytest

```python
import pytest
from httpx import AsyncClient

# Fixtures
@pytest.fixture
def sample_user():
    return {"name": "Test", "email": "test@example.com"}

@pytest.fixture
async def async_client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

# Tests
def test_create_user(sample_user):
    user = User(**sample_user)
    assert user.name == "Test"

@pytest.mark.asyncio
async def test_get_users(async_client):
    response = await async_client.get("/users")
    assert response.status_code == 200

# Parametrized tests
@pytest.mark.parametrize("email,valid", [
    ("valid@example.com", True),
    ("invalid", False),
    ("@nodomain.com", False),
])
def test_email_validation(email, valid):
    assert is_valid_email(email) == valid
```

## Configuration

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    api_prefix: str = "/api/v1"

    class Config:
        env_file = ".env"

settings = Settings()
```

## Logging

```python
import logging
from rich.logging import RichHandler

logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    handlers=[RichHandler(rich_tracebacks=True)]
)

logger = logging.getLogger(__name__)

logger.info("Processing started", extra={"user_id": 123})
logger.error("Failed to process", exc_info=True)
```

## Scripting

```python
#!/usr/bin/env python3
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Process files")
    parser.add_argument("input", type=Path, help="Input file")
    parser.add_argument("-o", "--output", type=Path, help="Output file")
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()

    if args.verbose:
        print(f"Processing {args.input}")

    # Process...

if __name__ == "__main__":
    main()
```

## Undvik

- `from module import *` - explicit imports
- Mutable default arguments - `def foo(items=None):`
- Bare `except:` - fånga specifika exceptions
- Global state - dependency injection
- `type()` för typcheck - `isinstance()`
