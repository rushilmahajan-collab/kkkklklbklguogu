# LifeOS — Your Personal Board of Directors

Treat your life like a company. Get AI-powered executives — CFO, CTO, EA, CEO, COO, CMO, CHRO — working 24/7 for you.

## Stack

- **Frontend**: Next.js 16 + TypeScript + Tailwind CSS + React Flow
- **Backend**: FastAPI (Python) + SQLAlchemy + SQLite
- **AI**: Anthropic Claude (claude-opus-4-6)
- **Auth**: JWT (python-jose + bcrypt)

## Features

- **Org Chart Builder** — Drag-and-drop interactive org chart with React Flow
- **AI Chat** — Real-time streaming conversations with each executive
- **CFO** — Financial analysis, budget planning (Plaid integration)
- **Executive Assistant** — Calendar, scheduling, task prioritization (Google Calendar)
- **CTO** — Tech stack management, automation, tool recommendations
- **CEO** — Strategic planning and direction
- **+ more** — COO, CMO, CHRO, or build custom executives
- **Integrations** — Plaid, Google Calendar, GitHub, Notion, Slack, and more

## Quick Start

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY
uvicorn app.main:app --reload --port 8000
```

### Frontend

```bash
cd frontend
npm install
cp .env.example .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Environment Variables

### Backend (`backend/.env`)

```env
SECRET_KEY=your-secret-key-min-32-chars
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Optional integrations
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENV=sandbox
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

### Frontend (`frontend/.env.local`)

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

## Project Structure

```
├── backend/
│   ├── app/
│   │   ├── api/routes/     # auth, agents, conversations, integrations
│   │   ├── core/           # config, database, security
│   │   ├── models/         # SQLAlchemy models
│   │   └── services/       # business logic, AI service
│   └── requirements.txt
└── frontend/
    ├── src/
    │   ├── app/            # Next.js App Router pages
    │   ├── lib/            # API client, utilities
    │   ├── store/          # Zustand state management
    │   └── types/          # TypeScript types
    └── package.json
```

## API Docs

Once the backend is running, visit [http://localhost:8000/docs](http://localhost:8000/docs) for the interactive Swagger UI.
