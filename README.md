# CDR Data Upload & Search System

Telecom Investigation & Intelligence Platform — full-stack implementation of the PRD.

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Angular 17 + TypeScript + SCSS |
| Backend | Node.js + Express + TypeScript |
| Database | PostgreSQL 15 (GIN FTS indexes) |
| Queue | BullMQ + Redis |
| Auth | JWT + bcrypt |
| Container | Docker + Docker Compose |

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (for local dev)

### Run with Docker (recommended)

```bash
docker-compose up --build
```

- Frontend: http://localhost:4200
- Backend API: http://localhost:3000
- API Health: http://localhost:3000/api/health

### Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@cdr-system.local | Admin@123 |
| Analyst | analyst@cdr-system.local | Analyst@123 |

### Local Development

**Backend:**
```bash
cd backend
cp .env.example .env
npm install
npm run migrate
npm run seed
npm run dev
```

**Frontend:**
```bash
cd frontend
npm install
npm start
```

## Features Implemented

### Upload (FR-U-01 to FR-U-08)
- Drag-and-drop + file picker for CSV/XLSX/XLS
- Per-file and overall progress bars
- Background processing via BullMQ workers (4 concurrent)
- Auto field detection with fuzzy alias matching (30+ aliases)
- Upload summary with record/error counts
- Batch tracking with UUID upload IDs

### Search (FR-S-01 to FR-S-09)
- Global keyword search using PostgreSQL FTS (GIN index)
- Advanced field-level filters: phone, name, IMEI, city, date range, call type, etc.
- Paginated results (50–500 rows/page)
- Row detail slide-over panel with all 30+ fields
- Export to CSV and Excel
- URL-encoded search state (shareable links)
- Audit logging of all searches

### Data Management (FR-M-01 to FR-M-05)
- Upload dashboard with stats
- Preview first 100 records per batch
- Soft-delete with confirmation dialog
- 7-day purge cycle (soft-delete flag)

### Security
- JWT authentication (HttpOnly-compatible)
- Rate limiting on auth and search endpoints
- Helmet.js security headers
- Input validation with express-validator
- Audit log for searches and deletions

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Login |
| GET | /api/auth/me | Current user |
| POST | /api/uploads | Create batch |
| POST | /api/uploads/:id/files | Upload files |
| GET | /api/uploads | List batches |
| GET | /api/uploads/:id | Batch details |
| GET | /api/uploads/:id/preview | First 100 records |
| DELETE | /api/uploads/:id | Soft-delete batch |
| GET | /api/search?q= | Global search |
| POST | /api/search/advanced | Field-level search |
| GET | /api/search/export | Export CSV/XLSX |
| GET | /api/records/:id | Full record detail |
| GET | /api/health | Health check |

## Database Schema

- `uploads` — batch metadata, status tracking
- `cdr_records` — 30+ CDR fields, GIN FTS index, B-tree indexes on key fields
- `users` — authentication
- `audit_logs` — search and deletion audit trail

## Field Mapping

The system auto-maps 30+ column name variants to canonical fields.
Example: "A Party", "Calling Number", "MSISDN" → `cdr_number`

See `backend/src/utils/fieldMapper.ts` for all aliases.
