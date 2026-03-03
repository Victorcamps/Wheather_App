import requests
from dotenv import load_dotenv
import os
from serpapi import GoogleSearch
from flask import Flask, jsonify
import json
from datetime import datetime, timedelta

load_dotenv()

#creating a server instance
app = Flask(__name__)

#API keys 
SERPAPI_KEY = os.getenv("SERP_API_KEY")
WEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
TICKETMASTER_KEY = os.getenv("TICKETMASTER_API_KEY")


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
        next_6_codes = data['hourly']['weather_code'][current_index:current_index + 6]

        hourly_forecast = [
            {
                "time" : next_6_hours[i].split("T")[1],
                "temp" : f"{next_6_temperatures[i]}°C",
                "description": get_weather_description(next_6_codes[i])[0]
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

# Fetch real local places using OpenStreetMap Overpass API
def get_local_places(city, lat, lon, suggestion):
    
    overpass_url = "http://overpass-api.de/api/interpreter"
    if suggestion == "outdoor":
        query = f"""
        [out:json];
        (
          node["leisure"="park"](around:5000,{lat},{lon});
          node["leisure"="nature_reserve"](around:5000,{lat},{lon});
          node["amenity"="marketplace"](around:5000,{lat},{lon});
        );
        out 3;
        """
    else:
        query = f"""
        [out:json];
        (
          node["tourism"="museum"](around:5000,{lat},{lon});
          node["amenity"="library"](around:5000,{lat},{lon});
          node["amenity"="cafe"](around:5000,{lat},{lon});
        );
        out 3;
        """

    response = requests.post(overpass_url, data=query)
    data = response.json()

    blacklist = ["teribithia", "unnamed", "unknown", "test", "temp"]
    places = []
    seen_names = set()

    for element in data.get('elements', []):
        tags = element.get('tags', {})
        name = tags.get('name', '').strip()

        if not name:
            continue
        if len(name) < 4:
            continue
        if name.lower() in seen_names:
            continue
        if any(word in name.lower() for word in blacklist):
            continue

        seen_names.add(name.lower())

        place_type = (
            tags.get('tourism') or
            tags.get('leisure') or
            tags.get('amenity', 'Local')
        ).capitalize()

        # Generate Google Maps link using place name and city
        maps_query = f"{name} {city}".replace(' ', '+')
        google_maps_link = f"https://www.google.com/maps/search/{maps_query}"

        places.append({
            "title": f"Visit {name}",
            "date": "Today",
            "location": city,
            "type": place_type,
            "link": google_maps_link  # Added Google Maps link
        })

        if len(places) >= 3:
            break

    return places




# Check if event date is valid
def is_event_valid(date_str):
    try:
        today = datetime.now()
        today_str = today.strftime("%b %-d")  # e.g. "Mar 3"
        today_str_alt = today.strftime("%B %-d")  # e.g. "March 3"

        if date_str.lower() == "today":
            return True
        if date_str == today_str or date_str == today_str_alt:
            return True

        return False
    except Exception:
        return False
    
# Function that search for ticketmaster events in the city
def get_ticketmaster_events(city, lat, lon, suggestion):
    url = "https://app.ticketmaster.com/discovery/v2/events.json"
    
    if suggestion == "outdoor":
        classifications = "Sports,Miscellaneous"
    else:
        classifications = "Arts & Theatre,Music,Comedy"

    params = {
        "apikey": TICKETMASTER_KEY,
        "city": city,
        "classificationName": classifications,
        "startDateTime": datetime.now().strftime("%Y-%m-%dT00:00:00Z"),
        "endDateTime": datetime.now().strftime("%Y-%m-%dT23:59:59Z"),
        "size": 5,
        "sort": "date,asc"
    }
    
    response = requests.get(url, params=params)
    data = response.json()

    events = []
    if "_embedded" in data:
        for event in data["_embedded"]["events"]:
            events.append({
                "title": event["name"],
                "date": event["dates"]["start"]["localDate"],
                "location": event["_embedded"]["venues"][0]["name"] if "_embedded" in event else city,
                "type": event["classifications"][0]["segment"]["name"] if "classifications" in event else "Event",
                "link": event.get("url", '')
            })
    return events


#function that search community/big events based on the forecast 
def get_events(city, region, country_code, suggestion, lat, lon):
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
        "htichips": "date:today",
        "api_key": SERPAPI_KEY
    }

    search = GoogleSearch(params)
    results = search.get_dict()

    events = []

    # SerpAPI results
    if "events_results" in results:
        for event in results["events_results"]:
            date_str = event['date']['start_date']
            if not is_event_valid(date_str):
                continue
            events.append({
                "title": event['title'],
                "date": date_str,
                "location": event.get('address', ['N/A'])[0],
                "type": event.get('type', 'N/A'),
                "link": event.get('link', '')
            })
            if len(events) >= 5:
                break

    # Fill remaining spots with Ticketmaster
    if len(events) < 5:
        tm_events = get_ticketmaster_events(city, lat, lon, suggestion)
        needed = 5 - len(events)
        events.extend(tm_events[:needed])

    # Final fallback with OpenStreetMap
    if len(events) < 2:
        local_places = get_local_places(city, lat, lon, suggestion)
        needed = 2 - len(events)
        events.extend(local_places[:needed])

    return events

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
        weather['suggestion'],
        location["lat"],
        location['lon']
    )

    return jsonify({
        "location": location,
        "weather": weather,
        "events": events
    })


if __name__ == '__main__':
    app.run(debug=True, port=5000)

