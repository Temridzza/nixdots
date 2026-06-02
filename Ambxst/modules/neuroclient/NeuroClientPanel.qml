pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import qs.modules.neuroclient
import qs.modules.theme

Item {
    id: neuroClientPanel

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    width: NeuroClientState.open ? 420 : 0
    opacity: NeuroClientState.open ? 1 : 0
    z: 10
    clip: true

    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Rectangle {
        id: bg
        anchors.fill: parent
        // фон прозрачный
        color: Qt.rgba(0, 0, 0, 0)
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: -5
            verticalOffset: 0
            radius: 20
            samples: 16
            color: Config.colors.shadow // используем цвет тени из theme
        }
    }

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "/home/temridzza/Documents/NeuroClient/qml/Main.qml"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: {
            if (mouse.x < neuroClientPanel.width) return
            NeuroClientState.open = false
        }
    }
}