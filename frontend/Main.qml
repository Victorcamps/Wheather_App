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

    //Main window
    Rectangle{
        anchors.fill: parent

        property int currentHour: new Date().getHours()

        color:{
            if (currentHour >= 5 && currentHour < 8)
                        return "#ff7043"  // Dawn - warm orange
                    else if (currentHour >= 8 && currentHour < 12)
                        return "#1565c0"  // Morning - bright blue
                    else if (currentHour >= 12 && currentHour < 17)
                        return "#0288d1"  // Afternoon - light blue
                    else if (currentHour >= 17 && currentHour < 20)
                        return "#e64a19"  // Sunset - deep orange
                    else if (currentHour >= 20 && currentHour < 23)
                        return "#1a1a2e"  // Evening - dark navy
                    else
                        return "#0a0a1a"  // Night - near black
        }

        // Smooth color transition
            Behavior on color {
                ColorAnimation { duration: 1000 }
            }

            // Timer to update every minute
            Timer {
                interval: 60000
                running: true
                repeat: true
                onTriggered: parent.currentHour = new Date().getHours()
            }

        //ADD ANIMATIONS RELATED TO THE WEATHER -> CLOUDS / SUN / HALF SuN ...

        ScrollView{
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            contentWidth: root.width


            //Where the cards will appear
            Column{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: root.height * 0.05
                spacing: root.height*0.03
                width: parent.width

                // Weather information
                Rectangle{

                    id: weatherCard
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.width * 0.5
                    height: root.height * 0.32
                    radius: 20

                    gradient : Gradient{
                        GradientStop{position: 0; color:"#0f3460"}
                        GradientStop{position: 1; color:"#16213e"}
                    }

                    Behavior on rotation{
                        SmoothedAnimation {velocity:50}
                    }

                    transform: Rotation{
                        id:cardRotation
                        origin.x: weatherCard.width / 2
                        origin.y: weatherCard.height / 2
                        axis {x:0; y:0; z:0;}
                        angle:0
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true

                        onPositionChanged:{
                            var centerX = weatherCard.width/2
                            var centerY = weatherCard.height/2
                            var offsetX = (mouseX-centerX)/centerX
                            var offsetY = (mouseY - centerY)/centerY
                            cardRotation.axis.x = -offsetY
                            cardRotation.axis.y = offsetX
                            cardRotation.angle = 8
                        }

                        onExited:{
                            cardRotation.angle = 0
                        }
                    }

                    Column{
                        anchors.centerIn: parent
                        spacing: root.height * 0.015

                        Text{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.city
                            color: "white"
                            font.pixelSize: root.width * 0.035
                            font.bold: true
                        }

                        Text{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.temperature
                            color: "#d6ebff"
                            font.pixelSize: root.width * 0.05
                            font.bold: true
                            style: Text.Outline
                            styleColor: "#55aaddff"
                        }

                        Text{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: backend.description
                            color: "#a8a8b3"
                            font.pixelSize: root.width * 0.022
                        }

                        Row{
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: root.width*0.025

                            Text{
                                text: "Humidity: " + backend.humidity
                                color: "#a8a8b3"
                                font.pixelSize: root.width * 0.016
                            }

                            Text{
                                text: "Feels Like: " + backend.feelsLike
                                color: "#a8a8b3"
                                font.pixelSize: root.width * 0.016
                            }
                        }

                    }
                }

                //Insert the hourly Forecast

                Column{
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: root.height * 0.015

                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Hourly Forecast"
                    }


                    Row{
                        spacing: root.width * 0.015
                        padding: root.width * 0.01

                        Repeater{
                            model: backend.hourlyForecast

                            Rectangle{
                                width: root.width * 0.09
                                height: root.height * 0.13
                                radius: 12
                                color: "#16213e"
                                border.color: "#44ffffff"
                                border.width: 1

                                Column{
                                    anchors.centerIn: parent
                                    spacing: root.width*0.018

                                    Text{
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
                                }
                            }
                        }
                    }
                }





                // Events information
                Column{
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: root.height*0.015
                    width: root.width * 0.65

                    Text{
                        text: backend.suggestion === "outdoor" ? "☀️ Suggested Outdoor Events" : "🏠 Suggested Indoor Events"
                        color: "white"
                        font.pixelSize: root.width * 0.028
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Grid{
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: root.width < 600 ? 1 : 2
                        spacing: root.width * 0.02
                        bottomPadding: root.height * 0.1

                        Repeater{
                            model: backend.events

                            Rectangle{
                                width: root.width < 600 ? root.width * 0.65 : root.width * 0.3
                                height: root.height * 0.18
                                radius: 15
                                color: "#16213e"

                                gradient: Gradient{
                                    GradientStop{position:0.0; color:"#0f3460" }
                                    GradientStop{position: 1.0; color: "#16213e"}
                                }

                                border.color: "#44ffffff"
                                border.width: 1

                                Column{
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
                                                text: modelData.type !== "N/A" ? modelData.type : "event"
                                                color: "white"
                                                font.pixelSize: root.width * 0.012
                                                font.bold: true
                                            }
                                    }

                                    Text{
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.title
                                        color: "white"
                                        font.pixelSize: root.width * 0.018
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text{
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Date: " + modelData.date
                                        color: "#a8a8b3"
                                        font.pixelSize: root.width*0.014
                                    }

                                    Text{
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Location: " + modelData.location
                                        color: "#a8a8b3"
                                        font.pixelSize: root.width*0.014
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
