import requests
from dotenv import load_dotenv
import os

load_dotenv()

API_KEY = os.getenv("OPENWEATHER_API_KEY")

#function to locate the user location
def get_location():
    response = requests.get("http://ip-api.com/json/")
    data = response.json()
    
    if data['status'] == 'success':
        city = data['city']
        lat = data['lat']
        lon = data['lon']
        print(f"Location detected: {city}")
        print(f"Coordinates: {lat}, {lon}")
        return city, lat, lon
    else:
        print("Could not detect location")
        return None, None, None

#function to get the forecast for the user using their ip Address
def get_weather(city):
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}"
    response = requests.get(url)
    data = response.json()

    if response.status_code == 200:
        print(f"\n--- Weather for {data['name']} ---")
        print(f"Temperature: {data['main']['temp']}°F")
        print(f"Feels like: {data['main']['feels_like']}°F")
        print(f"Weather: {data['weather'][0]['description']}")
        print(f"Humidity: {data['main']['humidity']}%")
        print(f"Wind Speed: {data['wind']['speed']} m/s")
    else:
        print(f"Weather Error: {data['message']}")


# Run
city, lat, lon = get_location()
if city:
    get_weather(city)
