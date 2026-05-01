import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme


Item {
    anchors.fill: parent

    property string terminalOutput: ""

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // 🔹 ЛЕВАЯ ПАНЕЛЬ (группы команд)
        ScrollView {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            clip: true

            Column {
                id: groupsColumn
                width: parent.width
                spacing: 6

                CommandGroup {
                    title: "Tor"
                    commands: [
                        { name: "Start", cmd: "systemctl start tor" },
                        { name: "Stop", cmd: "systemctl stop tor" },
                        { name: "Restart", cmd: "systemctl restart tor" }
                    ]
                    onCommandTriggered: runCommand
                }

                CommandGroup {
                    title: "ByDPI"
                    commands: [
                        { name: "Enable", cmd: "bydpi on" },
                        { name: "Disable", cmd: "bydpi off" }
                    ]
                    onCommandTriggered: runCommand
                }
            }
        }

        
    }

    // 🔥 запуск команды (заглушка)
    function runCommand(cmd) {
        terminalOutput += "$ " + cmd + "\n";
        terminalOutput += "executed...\n\n";
    }
}