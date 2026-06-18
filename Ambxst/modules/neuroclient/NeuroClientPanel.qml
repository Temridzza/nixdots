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

    // -------------------------------------------------
    // 1️⃣ Состояние (читаем из глобального объекта)
    // -------------------------------------------------
    property bool isOpen: NeuroClientState.open
    property int leftPanelWidth: 0               // если нужен наружу

    // ---------------- layer‑shell (Wayland) ----------
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: isOpen ? -1 : 0
    WlrLayershell.keyboardFocus: isOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    // ---------------- геометрия -----------------------
    anchors {
        top: parent.top
        bottom: parent.bottom
        right: parent.right          // <‑‑ «прямо от правого края»
    }
    // отступ от краёв экрана (можно менять)
    

    // Поскольку панель всегда живёт, а не создаётся‑уничтожается,
    // задаём фиксированную ширину (можно сделать «auto» через
    // implicitWidth, если нужен адаптивный размер)
    implicitWidth: 700
    implicitHeight: 100

    // -------------------------------------------------
    // 2️⃣ Внешний вид окна (тёмный полупрозрачный фон)
    // -------------------------------------------------
    color: "transparent"   // внешний цвет – полностью прозрачный
    visible: isOpen ? 1 : 0           // окно живёт всё время, а анимация – в контейнере

    // ------------------- контейнер --------------------
    Item {
        id: container
        anchors.fill: parent

        // Плавно появляем/исчезаем панель
        opacity: root.isOpen ? 1 : 0
        scale:   root.isOpen ? 1 : 0.95   // небольшое уменьшение при закрытии

        Behavior on opacity {
            NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutCubic }
        }

        // ----------------- фон панели -----------------
        StyledRect {
            id: backgroundRect
            anchors {
                fill: parent
                //leftMargin: 12
                //rightMargin: 12
                topMargin: 40
                bottomMargin: 8
            }
            

            variant: "common"          // ваш стиль (можно заменить на обычный Rectangle)
            radius: Styling.radius(15)
            color: Colors.background

            layer.enabled: true
            layer.effect: DropShadow {
                verticalOffset: 4
                radius: 12
                color: Config.resolveColor(Config.theme.shadowColor)
                samples: 16
            }

            Item {
                anchors.fill: parent

                Loader {
                    anchors.fill: parent
                    active: root.isOpen
                    source: "/home/temridzza/Documents/NeuroClient/qml/Main.qml"
                }
            }
        }

        
    } // <‑‑ конец container
    Connections {
        target: NeuroClientState
    }
}