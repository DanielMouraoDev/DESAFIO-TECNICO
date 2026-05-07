# Meu Projeto Edu

An educational platform with backend, frontend, and mobile components.

## Structure

- `backend/`: Django API with Django Ninja
- `frontend/`: Next.js web application with Tailwind CSS
- `mobile/`: Flutter mobile app
- `infra/`: Docker and Docker Compose setup
- `PRD.md`: Product Requirements Document
- `TechSpecs.md`: Technical Specifications

## Getting Started

### Backend
1. cd backend
2. .\venv\Scripts\Activate.ps1
3. python manage.py runserver

### Frontend
1. cd frontend
2. npm install
3. npm run dev

### Mobile
See mobile/README.md

### Infrastructure
1. cd infra
2. docker-compose up --build

## AI Journey

This project was developed with the assistance of AI tools like Claude and GPT as co-pilots. Here are some complex problems solved using AI:

1. **Configuring Django Ninja API with Schemas and Service Layer**: I used AI to design a clean architecture separating business logic into services.py, while implementing Ninja Schemas for input validation and automatic OpenAPI documentation. This ensured security and maintainability, similar to Spring's service layer and DTOs.

2. **Implementing Offline-First Flutter App with Sync Manager**: AI helped me set up Riverpod for state management, integrate connectivity_plus for network monitoring, and build a SyncManager that uploads pending data when connectivity returns. This created a robust offline-first experience with local SQLite storage.

3. **Setting Up Multi-Service Docker Orchestration**: With AI guidance, I configured Docker Compose to orchestrate backend (Django), frontend (Next.js), and database (PostgreSQL) services, ensuring proper networking and volume management for development and production environments.