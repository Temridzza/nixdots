pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.modules.neuroclient
import qs.modules.theme
import qs.modules.components
import qs.config
import qs.modules.globals

PanelWindow {
    id: root

    property bool isOpen: NeuroClientState.open
    property real animatedWidth: 0   // для анимации

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        right: true
    }

    // --------------------------------------------------
    // Target implicitWidth = source of truth
    // --------------------------------------------------
    implicitWidth: animatedWidth
    implicitHeight: parent ? parent.height : 0

    // --------------------------------------------------
    // Open / Close
    // --------------------------------------------------
    Component.onCompleted: animatedWidth = isOpen ? 600 : 0
    onIsOpenChanged: animatedWidth = isOpen ? 600 : 0

    // --------------------------------------------------
    // Smooth animation
    // --------------------------------------------------
    Behavior on animatedWidth {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.05
        }
    }

    // --------------------------------------------------
    // UI
    // --------------------------------------------------
    color: "transparent"
    visible: true

    Item {
        id: container
        anchors.fill: parent

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.98

        Behavior on opacity { NumberAnimation { duration: Config.animDuration } }
        Behavior on scale { NumberAnimation { duration: Config.animDuration } }

        Item {
            anchors.fill: parent
            anchors.margins: 12

            Loader {
                anchors.fill: parent
                active: root.isOpen
                source: "/home/temridzza/Documents/NeuroClient/qml/Main.qml"
            }
        }
    }

    Connections { target: NeuroClientState }
}