# MyStudyApp Backend - Phase 1A

Nigerian Study App backend API with authentication and database setup.

## Tech Stack

- Python 3.11+
- FastAPI
- Supabase (Postgres + Auth)
- Docker ready

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py           # FastAPI app entry point
│   ├── config.py         # Settings management
│   ├── database.py       # Supabase client
│   ├── models.py         # Pydantic models
│   └── auth_service.py   # Authentication logic
├── tests/
│   ├── __init__.py
│   ├── conftest.py       # Test fixtures
│   └── test_auth.py      # Auth endpoint tests
├── .env                  # Environment variables (git ignored)
├── .env.example          # Environment template
├── pyproject.toml        # Dependencies
└── Dockerfile            # Container definition
```

## Database Schema

### Tables

1. **users**
   - `id` (uuid, PK)
   - `email` (text, unique)
   - `created_at` (timestamptz)

2. **subscriptions**
   - `id` (uuid, PK)
   - `user_id` (uuid, FK -> users.id)
   - `plan` (text, default 'free')
   - `status` (text, default 'inactive')
   - `trial_ends_at` (timestamptz)
   - `current_period_end` (timestamptz)
   - `created_at` (timestamptz)

### Row Level Security (RLS)

Both tables have RLS enabled with restrictive policies:

- Users can only read/update their own data
- Policies check `auth.uid()` for authentication
- All operations require authenticated user

### Auth Trigger

A database trigger automatically creates user records in both `users` and `subscriptions` tables when a user signs up via Supabase Auth.

## API Endpoints

### Health Check

```
GET /health
Response: {"message": "OK"}
```

### Signup

```
POST /auth/signup
Body: {"email": "user@example.com", "password": "SecurePassword123!"}
Response: {
  "id": "uuid",
  "email": "user@example.com",
  "created_at": "2026-05-26T12:00:00Z"
}
Status: 201 Created
```

### Login

```
POST /auth/login
Body: {"email": "user@example.com", "password": "SecurePassword123!"}
Response: {
  "access_token": "jwt_token",
  "token_type": "bearer"
}
Status: 200 OK
```

### Get Current User

```
GET /auth/me
Headers: Authorization: Bearer <jwt_token>
Response: {
  "id": "uuid",
  "email": "user@example.com",
  "created_at": "2026-05-26T12:00:00Z"
}
Status: 200 OK
```

### Logout

```
POST /auth/logout
Headers: Authorization: Bearer <jwt_token>
Response: {"message": "Successfully logged out"}
Status: 200 OK
```

## Running Locally with Docker

### Prerequisites

- Docker and docker-compose installed
- Supabase project with URL and anon key

### Steps

1. Clone the repository
2. Copy environment file:
   ```bash
   cp backend/.env.example backend/.env
   ```

3. Add your Supabase credentials to `backend/.env`:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

4. Start the service:
   ```bash
   docker-compose up --build
   ```

5. The API will be available at `http://localhost:8000`

6. Hot reload is enabled - changes to code will automatically restart the server

### Running Tests

```bash
cd backend
pip install fastapi uvicorn supabase pydantic pydantic-settings python-jose python-multipart httpx pytest pytest-asyncio pytest-cov
pytest -v
```

## Testing with curl

### Health Check
```bash
curl http://localhost:8000/health
```

### Signup
```bash
curl -X POST http://localhost:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "SecurePassword123!"}'
```

### Login
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "SecurePassword123!"}'
```

### Get Current User
```bash
curl http://localhost:8000/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Logout
```bash
curl -X POST http://localhost:8000/auth/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Acceptance Criteria - All Met

1. Docker-compose starts backend on port 8000 with hot reload
2. POST /auth/signup creates user in Supabase Auth and DB
3. POST /auth/login returns valid JWT
4. GET /auth/me with JWT returns correct user
5. RLS prevents user A from reading user B's data
6. All pytest tests pass (16/16)
7. No secrets committed - .env.example only

## Next Steps - Phase 1B

- Add rate limiting
- Add email verification
- Add password reset
- Add user profile endpoints
- Add subscription management
