import os
import requests
from io import BytesIO
from flask import Flask, request, send_file, jsonify
from rembg import remove, new_session
from PIL import Image

app = Flask(__name__)

# WICHTIG: Session global laden, damit sie nicht bei jedem Request neu startet (Speed-Up)
# "u2netp" ist das Lightweight-Modell für Server mit wenig RAM (Render Free Tier)
model_name = "u2netp"
session = new_session(model_name)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({"status": "running", "model": model_name}), 200

@app.route('/remove-bg', methods=['POST'])
def remove_background():
    try:
        # 1. URL aus dem Body holen
        data = request.json
        image_url = data.get('url')
        
        if not image_url:
            return jsonify({"error": "No URL provided"}), 400

        # 2. Bild downloaden
        # Stream=True spart RAM bei großen Bildern
        response = requests.get(image_url, stream=True)
        response.raise_for_status()
        
        # Bild in Memory laden (max size limitieren empfohlen, hier offen)
        input_image = Image.open(BytesIO(response.content)).convert("RGBA")

        # 3. Hintergrund entfernen (mit u2netp Session)
        output_image = remove(input_image, session=session)

        # 4. Ergebnis zurückgeben
        img_io = BytesIO()
        output_image.save(img_io, 'PNG')
        img_io.seek(0)

        return send_file(img_io, mimetype='image/png')

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Nur für lokalen Test. In Produktion nutzt Render 'gunicorn'.
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))
