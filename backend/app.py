import requests
from dotenv import load_dotenv
import os
from flask import Flask, jsonify, request
import json
from datetime import datetime
import anthropic

load_dotenv()

#creating a server instance
app = Flask(__name__)

#API keys 
CLAUDE_API_KEY = os.getenv("CLAUDE_API_KEY")

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

#function which prompt the bot asking for suggestions according to the given weather info
def get_ai_recommendations(city,region,weather):
    client = anthropic.Anthropic(api_key=CLAUDE_API_KEY)
    today = datetime.now().strftime("%B %d, %Y")

    system_prompt = """You are a local activity and place recommendation assistant. 
    You will receive weather data for a citu and must suggest specific, real places and activities to do according to the forecast. 
    Be creative and suggest both well-known AND hidden gem locations. Always respond in valid JSON format with exactly this structure:
    {
        "summary" : "A friendly 2-3 sentence overview of today's weather and general recommendation",
        "recommendations" : [
            {
                "title" : "Place or activity name",
                "type" : " Type (cafe,park,museum,activity,restaurant,etc)",
                "reason" : "Why this is pefect for today's weather",
                "location" : "Specific address or neighborhood"
            }
        ] 
    }
    Return exactly 6 recommendations. Mix well-knonw spots with hidden gems. 
    Only suggest real places that actually exists in the city.
    Do not inlcude any text outside the JSON"""

    user_prompt = f"""City: {city}, {region}
        Today's date: {today}
        Current weather: {weather['description']}
        Temperature: {weather['temperature']} °C
        Feels like: {weather['feels_like']} °C
        Humidity: {weather['humidity']} %
        Activity suggestion: {weather['suggestion']} activities recommended

        Based on this weather, suggest the best places to go and things to do in {city} today.
        Mix outdoor/indoor activities, specific local places, restaurants and cafes.
        Consider the weather carefully — if it's raining suggest cozy indoor spots,
        if it's sunny suggest outdoor gems, if it's cold suggest warm cafes etc.
        Important: today is {today} — do NOT suggest places that are permanently closed
        or typically closed on {datetime.now().strftime("%A")}s."""


    message = client.messages.create(
        model = "claude-sonnet-4-20250514",
        max_tokens = 1000,
        system = system_prompt,
        messages = [
            {"role" : "user", "content" : user_prompt}
        ]
    )

    response_text = message.content[0].text

    clean = response_text.replace("```json","").replace("```","").strip()

    return json.loads(clean)


@app.route('/data', methods=['GET'])
def get_data():
    location = get_location()
    if not location:
        return jsonify({"error": "Could not detect location"}), 500

    weather = get_weather(location['lat'], location['lon'])
    if not weather:
        return jsonify({"error": "Could not fetch weather"}), 500

    weather['city'] = location['city']

    # Get AI recommendations
    ai_data = get_ai_recommendations(
        location['city'],
        location['region'],
        weather
    )

    return jsonify({
        "location": location,
        "weather": weather,
        "summary": ai_data.get('summary', ''),
        "events": ai_data.get('recommendations', [])
    })

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message', '')
    weather_context = data.get('weather', {})
    location_context = data.get('location', {})

    client = anthropic.Anthropic(api_key=CLAUDE_API_KEY)

    system_prompt = f"""You are a helpful local activity assistant for a weather app.
Current weather in {location_context.get('city')}, {location_context.get('region')}:
- Temperature: {weather_context.get('temperature')}°C
- Feels like: {weather_context.get('feels_like')}°C
- Weather: {weather_context.get('description')}
- Humidity: {weather_context.get('humidity')}%
- Wind: {weather_context.get('wind_speed')} m/s
- Suggestion: {weather_context.get('suggestion')} activities

Give specific, helpful recommendations for places and activities in {location_context.get('city')}.
Be friendly and concise. Keep responses under 150 words."""

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=300,
        system=system_prompt,
        messages=[
            {"role": "user", "content": user_message}
        ]
    )

    return jsonify({
        "response": message.content[0].text
    })


if __name__ == '__main__':
    app.run(debug=True, port=5000)

