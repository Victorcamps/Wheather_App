import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    minimumWidth: 400
    minimumHeight: 500
    title: "Wheather"

    // Move currentHour to root level so it's accessible everywhere
    property int currentHour: new Date().getHours()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentHour = new Date().getHours()
    }


    property var currentColors: {
        var desc = backend.description

        // Bad weather overrides time of day
        var badWeather = {
            "Overcast":       { day: ["#546e7a", "#90a4ae"], night: ["#1c2a30", "#0f1a20"] },
            "Cloudy":         { day: ["#546e7a", "#90a4ae"], night: ["#1c2a30", "#0f1a20"] },
            "Foggy":          { day: ["#607d8b", "#b0bec5"], night: ["#1a2030", "#0d1520"] },
            "Icy fog":        { day: ["#607d8b", "#b0bec5"], night: ["#1a2030", "#0d1520"] },
            "Light drizzle":  { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Drizzle":        { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Heavy drizzle":  { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Slight rain":    { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Rain":           { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Heavy rain":     { day: ["#263238", "#37474f"], night: ["#111a1a", "#0a1010"] },
            "Slight showers": { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Showers":        { day: ["#37474f", "#546e7a"], night: ["#1a2a2a", "#0d1a1a"] },
            "Heavy showers":  { day: ["#263238", "#37474f"], night: ["#111a1a", "#0a1010"] },
            "Slight snow":    { day: ["#b0bec5", "#eceff1"], night: ["#1a2030", "#0d1520"] },
            "Snow":           { day: ["#b0bec5", "#eceff1"], night: ["#1a2030", "#0d1520"] },
            "Heavy snow":     { day: ["#90a4ae", "#eceff1"], night: ["#1a2030", "#0d1520"] },
            "Thunderstorm":   { day: ["#212121", "#37474f"], night: ["#111111", "#1a1a1a"] },
            "Thunderstorm with hail": { day: ["#111111", "#212121"], night: ["#080808", "#111111"] }
        }


        // Check if bad weather first
        var colors = badWeather[desc]
        if (colors) {
            return isDaytime ? colors.day : colors.night
        }

        // Clear/partly cloudy weather follows time of day
        if (currentHour >= 5  && currentHour < 8)  return ["#ff7043", "#b0d4f1"]
        if (currentHour >= 8  && currentHour < 12) return ["#1565c0", "#e3f2fd"]
        if (currentHour >= 12 && currentHour < 17) return ["#0288d1", "#e1f5fe"]
        if (currentHour >= 17 && currentHour < 18) return ["#e64a19", "#edbca4"]
        if (currentHour >= 18 && currentHour < 23) return ["#1a1a2e", "#16213e"]
        return ["#0a0a1a", "#1a1a2e"]
    }

    property string bgTopColor: currentColors[0]
    property string bgBottomColor: currentColors[1]

    property bool isDaytime: currentHour >= 6 && currentHour < 18


    function getWeatherIcon(description, isDay) {
        var icons = {
            "Clear sky":      isDay ? "qrc:/WeatherApp/icons/clear-day.svg"
                                    : "qrc:/WeatherApp/icons/clear-night.svg",
            "Mainly clear":   isDay ? "qrc:/WeatherApp/icons/clear-day.svg"
                                    : "qrc:/WeatherApp/icons/clear-night.svg",
            "Partly cloudy":  isDay ? "qrc:/WeatherApp/icons/partly-cloudy-day.svg"
                                    : "qrc:/WeatherApp/icons/partly-cloudy-night.svg",
            "Overcast":       isDay ? "qrc:/WeatherApp/icons/overcast-day.svg"
                                    : "qrc:/WeatherApp/icons/overcast-night.svg",
            "Cloudy":         "qrc:/WeatherApp/icons/cloudy.svg",
            "Foggy":          isDay ? "qrc:/WeatherApp/icons/fog-day.svg"
                                    : "qrc:/WeatherApp/icons/fog-night.svg",
            "Icy fog":        "qrc:/WeatherApp/icons/fog.svg",
            "Light drizzle":  isDay ? "qrc:/WeatherApp/icons/partly-cloudy-day-drizzle.svg"
                                    : "qrc:/WeatherApp/icons/partly-cloudy-night-drizzle.svg",
            "Drizzle":        "qrc:/WeatherApp/icons/drizzle.svg",
            "Heavy drizzle":  "qrc:/WeatherApp/icons/drizzle.svg",
            "Slight rain":    isDay ? "qrc:/WeatherApp/icons/partly-cloudy-day-rain.svg"
                                    : "qrc:/WeatherApp/icons/partly-cloudy-night-rain.svg",
            "Rain":           "qrc:/WeatherApp/icons/rain.svg",
            "Heavy rain":     "qrc:/WeatherApp/icons/rain.svg",
            "Slight showers": isDay ? "qrc:/WeatherApp/icons/partly-cloudy-day-rain.svg"
                                    : "qrc:/WeatherApp/icons/partly-cloudy-night-rain.svg",
            "Showers":        "qrc:/WeatherApp/icons/rain.svg",
            "Heavy showers":  "qrc:/WeatherApp/icons/rain.svg",
            "Slight snow":    isDay ? "qrc:/WeatherApp/icons/partly-cloudy-day-snow.svg"
                                    : "qrc:/WeatherApp/icons/partly-cloudy-night-snow.svg",
            "Snow":           "qrc:/WeatherApp/icons/snow.svg",
            "Heavy snow":     "qrc:/WeatherApp/icons/snow.svg",
            "Thunderstorm":   isDay ? "qrc:/WeatherApp/icons/thunderstorms-day.svg"
                                    : "qrc:/WeatherApp/icons/thunderstorms-night.svg",
            "Thunderstorm with hail": "qrc:/WeatherApp/icons/thunderstorms-rain.svg"
        }
        return icons[description] || "qrc:/WeatherApp/icons/not-available.svg"
    }



    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: root.bgTopColor }
            GradientStop { position: 1.0; color: root.bgBottomColor }
        }

        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            contentWidth: root.width

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: root.height * 0.05
                spacing: root.height * 0.03
                width: parent.width

                // Weather Card
                Rectangle {
                    id: weatherCard
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.width * 0.5
                    height: root.height * 0.32
                    radius: 20

                    gradient: Gradient {
                        GradientStop { position: 0; color: "#0f3460" }
                        GradientStop { position: 1; color: "#16213e" }
                    }

                    Behavior on rotation {
                        SmoothedAnimation { velocity: 50 }
                    }

                    transform: Rotation {
                        id: cardRotation
                        origin.x: weatherCard.width / 2
                        origin.y: weatherCard.height / 2
                        axis { x: 0; y: 0; z: 0 }
                        angle: 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onPositionChanged: {
                            var centerX = weatherCard.width / 2
                            var centerY = weatherCard.height / 2
                            var offsetX = (mouseX - centerX) / centerX
                            var offsetY = (mouseY - centerY) / centerY
                            cardRotation.axis.x = -offsetY
                            cardRotation.axis.y = offsetX
                            cardRotation.angle = 8
                        }

                        onExited: {
                            cardRotation.angle = 0
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: root.height * 0.015

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.city
                            color: "white"
                            font.pixelSize: root.width * 0.035
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.temperature
                            color: "#d6ebff"
                            font.pixelSize: root.width * 0.05
                            font.bold: true
                            style: Text.Outline
                            styleColor: "#55aaddff"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.description
                            color: "#a8a8b3"
                            font.pixelSize: root.width * 0.022
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: root.width * 0.025

                            Text {
                                text: "Humidity: " + backend.humidity
                                color: "#a8a8b3"
                                font.pixelSize: root.width * 0.016
                            }

                            Text {
                                text: "Feels Like: " + backend.feelsLike
                                color: "#a8a8b3"
                                font.pixelSize: root.width * 0.016
                            }
                        }
                    }
                }

                // Hourly Forecast
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: root.height * 0.015

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Hourly Forecast"
                        color: "white"
                        font.pixelSize: root.width * 0.022
                        font.bold: true
                    }

                    Row {
                        spacing: root.width * 0.015
                        padding: root.width * 0.01

                        Repeater {
                            model: backend.hourlyForecast


                            Rectangle {
                                width: root.width * 0.09
                                height: root.height * 0.2
                                radius: 12
                                color: "#16213e"
                                border.color: "#44ffffff"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: root.width * 0.018

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.time
                                        color: "#a8a8b3"
                                        font.pixelSize: root.width * 0.013
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.temp
                                        color: "#e8f4ff"
                                        font.pixelSize: root.width * 0.016
                                        font.bold: true
                                        style: Text.Outline
                                        styleColor: "#55aaddff"
                                    }

                                    Image {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: root.width * 0.05
                                        height: width
                                        source: getWeatherIcon(modelData.description, isDaytime)
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }
                            }
                        }
                    }
                }

                // Events Section
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: root.height * 0.015
                    width: root.width * 0.65

                    Text {
                        text: backend.suggestion === "outdoor" ? "☀️ Suggested Outdoor Events" : "🏠 Suggested Indoor Events"
                        color: "white"
                        font.pixelSize: root.width * 0.028
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: root.width < 600 ? 1 : 2
                        spacing: root.width * 0.02
                        bottomPadding: root.height * 0.1

                        Repeater {
                            model: backend.events

                            Rectangle {
                                width: root.width < 600 ? root.width * 0.65 : root.width * 0.3
                                height: root.height * 0.18
                                radius: 15
                                color: "#16213e"

                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#0f3460" }
                                    GradientStop { position: 1.0; color: "#16213e" }
                                }

                                border.color: "#44ffffff"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: root.height * 0.01
                                    width: parent.width * 0.85

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: typeText.width + 16
                                        height: typeText.height + 8
                                        radius: 5
                                        color: "#e94560"

                                        Text {
                                            id: typeText
                                            anchors.centerIn: parent
                                            text: modelData.type !== "N/A" ? modelData.type : "Event"
                                            color: "white"
                                            font.pixelSize: root.width * 0.012
                                            font.bold: true
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.title
                                        color: "white"
                                        font.pixelSize: root.width * 0.018
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Date: " + modelData.date
                                        color: "#a8a8b3"
                                        font.pixelSize: root.width * 0.014
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Location: " + modelData.location
                                        color: "#a8a8b3"
                                        font.pixelSize: root.width * 0.014
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
