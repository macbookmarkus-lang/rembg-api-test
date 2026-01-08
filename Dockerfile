FROM python:3.9-slim

# System-Abhängigkeiten für Pillow/Opencv (benötigt von rembg)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Requirements installieren
COPY requirements.txt .
# --no-cache-dir spart Speicherplatz im Image
RUN pip install --no-cache-dir -r requirements.txt

# Den Rest kopieren
COPY . .

# Download des u2netp Modells beim Build (damit der erste Request schnell ist)
RUN python -c "from rembg import new_session; new_session('u2netp')"

# Gunicorn Startbefehl (Production Server)
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app", "--timeout", "120"]
