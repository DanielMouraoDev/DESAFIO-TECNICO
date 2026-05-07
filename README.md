An educational platform with backend, frontend, and mobile components.

Structure
backend/: Django API with Django Ninja
frontend/: Next.js web application with Tailwind CSS
mobile/: Flutter mobile app
infra/: Docker and Docker Compose setup
PRD.md: Product Requirements Document
TechSpecs.md: Technical Specifications
Getting Started
Backend
cd backend
.\venv\Scripts\Activate.ps1
python manage.py runserver
Frontend
cd frontend
npm install
npm run dev
Mobile
See mobile/README.md

Infrastructure
cd infra
docker-compose up --build
