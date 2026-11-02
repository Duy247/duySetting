import QtQuick
Rectangle {
    id: root
    color: "black"
    property int stage: 0
    Item {
        width: 420; height: 240
        anchors.centerIn: parent
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Item {
                width: 85; height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: -10
                Grid {
                    columns: 2; spacing: 4
                    Repeater {
                        model: ["#f35325", "#81bc06", "#05a6f0", "#ffba08"]
                        Rectangle { required property string modelData; width: 36; height: 32; color: modelData }
                    }
                }
            }
            Text { text: "Microsoft"; color: "white"; font.pixelSize: 18 }
            Row {
                Text { text: "Windows"; color: "white"; font.pixelSize: 52; font.bold: true }
                Text { text: "xp"; color: "#ef6b22"; font.pixelSize: 32; font.bold: true }
            }
        }
        Rectangle {
            width: 180; height: 20; radius: 4; color: "black"; border.color: "#a0a0a0"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            Item {
                anchors.fill: parent; anchors.margins: 3; clip: true
                Row {
                    spacing: 3; x: -45
                    Repeater {
                        model: 3
                        Rectangle { width: 11; height: 14; gradient: Gradient { GradientStop { position: 0; color: "#93b8ff" } GradientStop { position: 0.5; color: "#284ee8" } GradientStop { position: 1; color: "#142695" } } }
                    }
                    NumberAnimation on x { from: -45; to: 180; duration: 1600; loops: Animation.Infinite; running: true }
                }
            }
        }
    }
    Text { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.margins: 30; text: "Fedora Linux · KDE Plasma"; color: "#888888"; font.pixelSize: 14 }
}
