import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    minimumWidth: 400
    minimumHeight: 500
    title: "Weather & Events App"

    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"

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
                    width: root.width * 0.65
                    height: root.height * 0.32
                    radius: 20

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0f3460" }
                        GradientStop { position: 1.0; color: "#16213e" }
                    }

                    // Smooth transition for rotation
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
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onPositionChanged: {
                                // Calculate mouse offset from center
                                var centerX = weatherCard.width / 2
                                var centerY = weatherCard.height / 2

                                var offsetX = (mouseX - centerX) / centerX
                                var offsetY = (mouseY - centerY) / centerY

                                // Apply tilt based on mouse position
                                cardRotation.axis.x = -offsetY
                                cardRotation.axis.y = offsetX
                                cardRotation.angle = 8
                            }

                            onExited: {
                                // Reset rotation when mouse leaves
                                cardRotation.angle = 0
                            }
                        }


                Column {
                    anchors.centerIn: parent
                    spacing: root.height * 0.015

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Vancouver"
                        color: "white"
                        font.pixelSize: root.width * 0.035
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "18°C"
                        font.pixelSize: root.width * 0.06
                        font.bold: true
                        color: "#e8f4ff"
                        style: Text.Outline
                        styleColor: "#55aaddff"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Cloudy"
                        color: "#a8a8b3"
                        font.pixelSize: root.width * 0.022
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: root.width * 0.025

                        Text {
                            text: "Humidity: 60%"
                            color: "#a8a8b3"
                            font.pixelSize: root.width * 0.016
                        }

                        Text {
                            text: "Wind: 10 m/s"
                            color: "#a8a8b3"
                            font.pixelSize: root.width * 0.016
                        }

                        Text {
                            text: "Feels like: 15°C"
                            color: "#a8a8b3"
                            font.pixelSize: root.width * 0.016
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
                    text: "Suggested Events"
                    color: "white"
                    font.pixelSize: root.width * 0.028
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: root.width < 600 ? 1 : 2
                    spacing: root.width * 0.02

                    Repeater {
                        model: 4

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

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Event Name"
                                    color: "white"
                                    font.pixelSize: root.width * 0.02
                                    font.bold: true
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Jan 1, 2026"
                                    color: "#a8a8b3"
                                    font.pixelSize: root.width * 0.016
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Vancouver"
                                    color: "#a8a8b3"
                                    font.pixelSize: root.width * 0.016
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
