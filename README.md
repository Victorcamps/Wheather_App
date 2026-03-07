# 🌤 Wheather App

A desktop weather app that uses AI to suggest activities and places to visit based on your local forecast.

## Features

- Real-time weather detection based on your location
- Dynamic backgrounds and animations based on weather conditions
- Hourly forecast
- AI-powered activity recommendations

## Tech Stack

- **Frontend:** Qt/QML + C++
- **Backend:** Python Flask (deployed on Railway)
- **Weather:** Open-Meteo API (free, no key needed)
- **AI:** Anthropic Claude API

## How to Run

### Prerequisites

- Qt 6.5 or higher
- Qt Creator

### Steps

1. Clone the repository
   git clone https://github.com/victorcamps/Wheather_App.git

2. Open Qt Creator
   - Open the frontend/ folder as a project
   - Select CMakeLists.txt

3. Build and run
   - Press the green Run button in Qt Creator
   - The app will automatically connect to the live backend

## Notes

- No local backend setup needed — the Flask server is already deployed in the cloud
- The app detects your location automatically based on your IP address
- You will need your own Anthropic API key if you want to run the backend locally

## Running the Backend Locally (Optional)

1. Navigate to the backend/ folder
2. Create a .env file with your API key:
   CLAUDE_API_KEY=your_key_here
3. Install dependencies:
   pip install -r requirements.txt
4. Run the server:
   python app.py
5. Update mainwindow.cpp to point to http://localhost:5000 instead of the Railway URL
