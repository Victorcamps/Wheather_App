import requests
from dotenv import load_dotenv
import os
from serpapi import GoogleSearch

load_dotenv()

SERPAPI_KEY = os.getenv("SERP_API_KEY")

def get_location():
    response = requests.get("http://ip-api.com/json/")
    data = response.json()
    
    if data['status'] == 'success':
        city = data['city']
        region = data['regionName']
        country_code = data['countryCode'].lower()
        print(f"Location detected: {city}, {region}, {country_code.upper()}")
        return city, region, country_code
    else:
        print("Could not detect location")
        return None, None, None

def get_events(city, region, country_code, weather_condition=None):
    
    if weather_condition == "outdoor":
        query = f"outdoor events {city}"
    elif weather_condition == "indoor":
        query = f"indoor events {city}"
    else:
        query = f"events {city}"

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
        events = results["events_results"]
        print(f"\n--- Events in {city} ---")
        for event in events[:5]:
            print(f"\nEvent: {event['title']}")
            print(f"Date: {event['date']['start_date']}")
            print(f"Location: {event.get('address', ['N/A'])[0]}")
            print(f"Type: {event.get('type', 'N/A')}")
    else:
        print("No events found or error occurred")
        print(results)
# Run
city, region, country_code = get_location()
if city:
    get_events(city, region, country_code, "outdoor")