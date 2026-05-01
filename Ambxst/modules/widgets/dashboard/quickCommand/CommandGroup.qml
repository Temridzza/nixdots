import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    width: parent ? parent.width : implicitWidth
    implicitHeight: column.implicitHeight

    property string title
    property var commands: []
    signal commandTriggered(string cmd)

    property bool expanded: false

    Column {
        id: column
        width: parent.width
        spacing: 2

        // 🔹 Заголовок группы (нативный Qt стиль)
        Button {
            width: parent.width
            text: root.title
            checkable: true
            checked: root.expanded

            // визуально это будет работать под текущей Qt темой (Material/Fusion)
            // onToggled: root.expanded = checked
        }

        // 🔹 Контейнер команд
        Column {
            width: parent.width
            visible: root.expanded
            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }

            Repeater {
                model: root.commands

                delegate: Button {
                    width: parent.width
                    text: modelData.name
                    flat: true

                    // небольшое смещение вместо "  " (правильнее для темы)
                    leftPadding: 18

                    onClicked: root.commandTriggered(modelData.cmd)
                }
            }
        }
    }
}