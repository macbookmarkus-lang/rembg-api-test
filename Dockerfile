FROM python:3.9-slim

# Umgebungsvariable, damit apt nicht nach Eingaben fragt
ENV DEBIAN_FRONTEND=noninteractive

# Wir installieren ALLES, was OpenCV brauchen könnte
# libgl1: OpenGL Support
# libglib2.0-0: Core Library
# libsm6, libxext6, libxrender-dev: X11 Render Libraries (oft der Grund für Fehler)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Requirements installieren
COPY requirements.txt .
# Pip Upgrade, um Warnungen zu vermeiden
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Den Rest kopieren
COPY . .

# Home-Verzeichnis für U2NET setzen (verhindert Permission Errors)
ENV U2NET_HOME=/app/.u2net

# Modell herunterladen
RUN python -c "from rembg import new_session; new_session('u2netp')"

# Startbefehl
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app", "--timeout", "120"]
