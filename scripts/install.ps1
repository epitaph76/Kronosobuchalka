$ErrorActionPreference = "Stop"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python не найден в PATH. Поставь Python 3.11+ и повтори."
}

python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -e .

Write-Host ""
Write-Host "Готово."
Write-Host "Активировать окружение:"
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host ""
Write-Host "Проверка:"
Write-Host "  kronosobuchalka --help"

