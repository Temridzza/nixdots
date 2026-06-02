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


PanelWindow {
    id: root

    // ------------------------------------------------------------------
    // ВХОД: только состояние
    // ------------------------------------------------------------------
    property Item anchorItem // может быть null (мы не используем для anchor логики)
    property bool isOpen: NeuroClientState.open

    // ------------------------------------------------------------------
    // Геометрия панели (справа как sidebar)
    // ------------------------------------------------------------------
    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: isOpen ? 600 : 0

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
    visible: true   // PanelWindow ВСЕГДА живёт, мы не убиваем его

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

        StyledRect {
            anchors.fill: parent
            variant: "popup"
            radius: Styling.radius(10)
            enableShadow: true

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
    }

    // ------------------------------------------------------------------
    // СИНХРОНИЗАЦИЯ СО STATE (ВАЖНО)
    // ------------------------------------------------------------------
    Connections {
        target: NeuroClientState

        function onOpenChanged() {
            console.log("NeuroClientPanel state:", NeuroClientState.open)
        }
    }

    // ------------------------------------------------------------------
    // HYPRLAND focus grab (чтобы клики снаружи закрывали)
    // ------------------------------------------------------------------
    HyprlandFocusGrab {
        active: root.isOpen
        windows: [root]

        onCleared: {
            if (NeuroClientState.open) {
                NeuroClientState.open = false
            }
        }
    }

    // ------------------------------------------------------------------
    // DEBUG
    // ------------------------------------------------------------------
    Component.onCompleted: {
        console.log("NeuroClientPanel initialized")
    }
}