import QtQuick
import qs.modules.theme
import qs.modules.components
import qs.modules.globals

Rectangle {
    id: root
    width: 32
    height: 32
    radius: 8

    property alias icon: iconText.text
    property color accentColor: Colors.primary
    signal clicked

    color: mouse.pressed
        ? Qt.tint(accentColor, Qt.rgba(0,0,0,0.3))
        : mouse.containsMouse
            ? Qt.tint(accentColor, Qt.rgba(1,1,1,0.1))
            : "transparent"

    border.width: mouse.containsMouse ? 1 : 0
    border.color: accentColor

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Icons.font
        font.pixelSize: 16
        color: accentColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}