import requests

# The URL of your FastAPI OCR endpoint
url = "http://127.0.0.1:8000/ocr"

# Path to the image you want to test
image_path = "test.JPG"  # Change this to your image file name

# Open the file and send the request
with open(image_path, "rb") as f:
    files = {"file": f}
    response = requests.post(url, files=files)

# Print the response
print("Status Code:", response.status_code)
try:
    print("Response JSON:", response.json())
except Exception:
    print("Response Text:", response.text)
