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

    // ------------------------------------------------------------------
    // ВХОД: только состояние
    // ------------------------------------------------------------------
    property Item anchorItem
    property bool isOpen: NeuroClientState.open

    WlrLayershell.layer: isOpen ? WlrLayer.Overlay : WlrLayer.Background
    WlrLayershell.exclusiveZone: isOpen ? -1 : 0
    WlrLayershell.keyboardFocus: isOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    // ------------------------------------------------------------------
    // Геометрия панели (справа как sidebar)
    // ------------------------------------------------------------------
    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 20
    }

    implicitWidth: 600

    // важно: иначе будет "прыгать"
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutCubic
        }
    }

    // ------------------------------------------------------------------
    // ВНЕШНИЙ ВИД ОКНА
    // ------------------------------------------------------------------
    color: "transparent"
    visible: isOpen ? 1 : 0   // PanelWindow ВСЕГДА живёт, мы не убиваем его

    // ------------------------------------------------------------------
    // СЛОЙ UI
    // ------------------------------------------------------------------
    
    Item {
        id: container
        anchors.fill: parent
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.98

        Behavior on opacity {
            NumberAnimation { duration: Config.animDuration }
        }

        Behavior on scale {
            NumberAnimation { duration: Config.animDuration }
        }

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

    // ------------------------------------------------------------------
    // СИНХРОНИЗАЦИЯ СО STATE (ВАЖНО)
    // ------------------------------------------------------------------
    Connections {
        target: NeuroClientState
    }

    // ------------------------------------------------------------------
    // HYPRLAND focus grab (чтобы клики снаружи закрывали)
    // ------------------------------------------------------------------
    // HyprlandFocusGrab {
    //     active: root.isOpen
    //     windows: [root]

    //     onCleared: {
    //         if (NeuroClientState.open) {
    //             NeuroClientState.open = false
    //         }
    //     }
    // }
}