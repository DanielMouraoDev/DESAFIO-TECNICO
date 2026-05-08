python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

Write-Host ""
Write-Host "Virtual environment configured at backend/.venv" -ForegroundColor Green
Write-Host "To run the backend:" -ForegroundColor Cyan
Write-Host "  python manage.py migrate"
Write-Host "  python manage.py runserver 0.0.0.0:8000"

