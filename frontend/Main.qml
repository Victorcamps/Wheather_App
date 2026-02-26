import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    minimumWidth: 400
    minimumHeight: 500
    title: "Wheater"

    //Main window
    Rectangle{
        anchors.fill: parent

        property int currHour: new Date().getHours()

        color:{
            if (currentHour >= 5 && currentHour < 8)
                        return "#ff7043"  // Dawn - warm orange
                    else if (currentHour >= 8 && currentHour < 12)
                        return "#1565c0"  // Morning - bright blue
                    else if (currentHour >= 12 && currentHour < 17 && backend.suggestion == "outdoor")
                        return "#0288d1"  // Afternoon - light blue
                    else if (currentHour >= 12 && currentHour < 17 && backend.suggestion == "indoor")
                        return "78909c"
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

        //Where the cards will appear
        Column{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.height * 0.05
            spacing: root*height*0.03
            width: parent.width

            // Weather information
            Rectangle{

                id: weatherCard
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.width * 0.5
                height: root.height * 0.32
                radius: 20

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
            }
        }
    }
}
