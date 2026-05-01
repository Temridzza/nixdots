import QtQuick
import qs.modules.theme
import qs.modules.components
import qs.modules.globals

Rectangle {
    width: 32
    height: 32
    radius: 6
    color: "transparent"

    property alias icon: iconText.text
    signal clicked

    Text {
        id: iconText
        anchors.centerIn: parent
        font.family: Icons.font
        font.pixelSize: 16
        color: Colors.overBackground
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}