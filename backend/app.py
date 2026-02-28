import requests
from dotenv import load_dotenv
import os
from serpapi import GoogleSearch
from flask import Flask, jsonify
import json
from datetime import datetime

load_dotenv()

#creating a server instance
app = Flask(__name__)

#API keys 
SERPAPI_KEY = os.getenv("SERP_API_KEY")
WEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")


#function to locate the user region by using their ip address
def get_location():
    response = requests.get("http://ip-api.com/json/")
    data = response.json()

    
    if data['status'] == 'success':
        return{
            "city": data['city'],
            "region": data['regionName'],
            "country_code": data['countryCode'].lower(),
            "lat": data['lat'],
            "lon": data['lon']
        }
    return None


def get_weather_description(code):
    weather_codes = {
        0: ("Clear sky", "outdoor"),
        1: ("Mainly clear", "outdoor"),
        2: ("Partly cloudy", "outdoor"),
        3: ("Overcast", "outdoor"),
        45: ("Foggy", "indoor"),
        48: ("Icy fog", "indoor"),
        51: ("Light drizzle", "indoor"),
        53: ("Drizzle", "indoor"),
        55: ("Heavy drizzle", "indoor"),
        61: ("Slight rain", "indoor"),
        63: ("Rain", "indoor"),
        65: ("Heavy rain", "indoor"),
        71: ("Slight snow", "indoor"),
        73: ("Snow", "indoor"),
        75: ("Heavy snow", "indoor"),
        80: ("Slight showers", "indoor"),
        81: ("Showers", "indoor"),
        82: ("Heavy showers", "indoor"),
        95: ("Thunderstorm", "indoor"),
        99: ("Thunderstorm with hail", "indoor"),
    }
    return weather_codes.get(code, ("Unknown", "outdoor"))


#function that gets the city forecast and classify it as 'outdoor' or 'indoor' weather
def get_weather(lat, lon):
    url = "https://api.open-meteo.com/v1/forecast"

    params = {
        "latitude": lat,
        "longitude": lon,
        "current": "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m",
        "hourly": "temperature_2m,weather_code",
        "forecast_days": 2,
        "timezone": "auto"
    }

    response = requests.get(url, params=params)
    data = response.json()

    import json
    print("\n=== OPEN-METEO RAW DATA ===")
    print(json.dumps(data, indent=4))
    print("===========================\n")

    if response.status_code == 200:
        current = data['current']
        weather_code = current['weather_code']
        description, suggestion = get_weather_description(weather_code)

        #get current hour index
        current_time = datetime.now()
        hourly_times = data['hourly']['time']
        hourly_temperatures = data['hourly']['temperature_2m']


        #find index of the current hour in the hourly data
        current_hour_str = current_time.strftime("%Y-%m-%dT%H:00")

        try:
            current_index = hourly_times.index(current_hour_str)
        except ValueError:
            current_index=0

        #get next 6 hours starting from current hour
        next_6_hours = hourly_times[current_index:current_index+6]
        next_6_temperatures = hourly_temperatures[current_index:current_index+6]

        hourly_forecast = [
            {
                "time" : next_6_hours[i].split("T")[1],
                "temp" : f"{next_6_temperatures[i]}°C"
            }
            for i in range(len(next_6_hours))
        ]

        return {
            "city" : None,
            "temperature": round(current['temperature_2m'], 1),
            "feels_like": round(current['apparent_temperature'], 1),
            "humidity": current['relative_humidity_2m'],
            "wind_speed": round(current['wind_speed_10m'], 1),
            "description": description,
            "suggestion": suggestion,
            "hourly_forecast": hourly_forecast
        }
    return None



#function that search community/big events based on the forecast 
def get_events(city, region, country_code, suggestion):
    if suggestion == "outdoor":
        query = f"outdoor events {city}"
    else:
        query = f"indoor events {city}"

    params = {
        "engine": "google_events",
        "q": query,
        "hl": "en",
        "gl": country_code,
        "location": f"{city}, {region}",
        "api_key": SERPAPI_KEY
    }

    search = GoogleSearch(params)
    results = search.get_dict()

    if "events_results" in results:
        events = []
        for event in results["events_results"][:5]:
            events.append({
                "title": event['title'],
                "date": event['date']['start_date'],
                "location": event.get('address', ['N/A'])[0],
                "type": event.get('type', 'N/A')
            })
        return events
    return []

@app.route('/data', methods=['GET'])
def get_data():
    location = get_location()
    if not location:
        return jsonify({"error": "Could not detect location"}), 500

    weather = get_weather(location['lat'], location['lon'])
    if not weather:
        return jsonify({"error": "Could not fetch weather"}), 500

    # Add city name to weather data
    weather['city'] = location['city']

    events = get_events(
        location['city'],
        location['region'],
        location['country_code'],
        weather['suggestion']
    )

    return jsonify({
        "location": location,
        "weather": weather,
        "events": events
    })


if __name__ == '__main__':
    app.run(debug=True, port=5000)

