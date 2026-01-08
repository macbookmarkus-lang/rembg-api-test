FROM python:3.9-slim

# KORREKTUR: 'libgl1' statt 'libgl1-mesa-glx' für neuere Debian Versionen
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Requirements installieren
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Den Rest kopieren
COPY . .

# Download des u2netp Modells beim Build
RUN python -c "from rembg import new_session; new_session('u2netp')"

# Server Start
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app", "--timeout", "120"]
