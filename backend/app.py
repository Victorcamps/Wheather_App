import requests
from dotenv import load_dotenv
import os
from serpapi import GoogleSearch
from flask import Flask, jsonify
import json

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

#function that gets the city forecast and classify it as 'outdoor' or 'indoor' weather
def get_weather(city):
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={WEATHER_API_KEY}&units=metric"
    response = requests.get(url)
    data = response.json()
    
    print("\n=== WEATHER API RAW DATA ===")
    print(json.dumps(data, indent=4))
    print("============================\n")
    
    #get clouds information to make it easier to do the background color change and animation !!!!!!!!!!!!!!! 

    #Also get the daily forecast for the next 4 days


    if response.status_code == 200:
        condition = data['weather'][0]['main']
        
        # Determine outdoor or indoor suggestion
        if condition in ['Clear', 'Clouds']:
            suggestion = "outdoor"
        else:
            suggestion = "indoor"
        
        return {
            "city": data['name'],
            "temperature": data['main']['temp'],
            "feels_like": data['main']['feels_like'],
            "condition": condition,
            "description": data['weather'][0]['description'],
            "humidity": data['main']['humidity'],
            "wind_speed": data['wind']['speed'],
            "suggestion": suggestion,
            "clouds": data['clouds']['all']
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

# Defines the url endpoint
@app.route('/data', methods=['GET'])

#function that runs the endpoint and displays a JSON with all the data we collected previously
def get_data():
    location = get_location()
    if not location:
        return jsonify({"error": "Could not detect location"}), 500

    weather = get_weather(location['city'])
    if not weather:
        return jsonify({"error": "Could not fetch weather"}), 500

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

