pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.modules.globals
import qs.config

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 400

    property string hostname: ""
    property string osName: ""
    property string osIcon: ""
    property var linuxLogos: null
    property real chartZoom: 1.0

    property var services: [
        { name: "tor.service", label: "tor" },
        { name: "byedpi.service", label: "byeDpi"},
        { name: "jellyfin.service", label: "jellyfin" },
    ]
    property var scripts: [
        { label: "toggle-edp", command: "/etc/nixos/features/scripts/toggle-edp.sh" },
        { label: "run clion", command: "cd ~/jb/CLionProjects/Chat && nix-shell --command \"clion .\"" },
        
    ]
    property bool scriptsExpanded: false

    property int serviceIndex: 0

    property var serviceStates: ({})

    // Function to get OS icon based on name
    function getOsIcon(osName) {
        if (!osName || !linuxLogos) {
            return "";
        }

        // Try exact match first
        if (linuxLogos[osName]) {
            return linuxLogos[osName];
        }

        // Try partial match
        for (const distro in linuxLogos) {
            if (osName.toLowerCase().includes(distro.toLowerCase())) {
                return linuxLogos[distro];
            }
        }

        // Default to generic Linux icon
        return linuxLogos["Linux"] || "";
    }

    function getServiceState(name) {
        if (!root.serviceStates)
            return "unknown";

        return root.serviceStates[name] || "unknown";
    }

    // Update OS icon when logos are loaded
    onLinuxLogosChanged: {
        if (linuxLogos && osName) {
            const icon = getOsIcon(osName);
            osIcon = icon || "";
        }
    }

    // Load refresh interval from state
    Component.onCompleted: {
        // Always store maximum (250 points) to allow smooth zooming
        SystemResources.maxHistoryPoints = 250;

        const savedInterval = StateService.get("metricsRefreshInterval", 2000);
        SystemResources.updateInterval = Math.max(100, savedInterval);
        const savedZoom = StateService.get("metricsChartZoom", 1.0);
        // Limit zoom range: 0.2 (show all available) to 3.0 (zoom in)
        chartZoom = Math.max(0.2, Math.min(3.0, savedZoom));

        hostnameReader.running = true;
        osReader.running = true;
        linuxLogosReader.running = true;

        refreshServices();
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: refreshServices()
    }

    Process {
        id: serviceRunner
        running: false

        function run(service, action) {
            command = ["/run/current-system/sw/bin/systemctl", action, service];
            running = true;
        }
    }

    function runService(name, action) {
        serviceRunner.run(name, action);

        // чуть позже обновим статус
        Qt.callLater(() => refreshServices());
    }

    // Load Linux logos JSON
    Process {
        id: linuxLogosReader
        running: false
        command: ["cat", Qt.resolvedUrl("../../../../assets/linux-logos.json").toString().replace("file://", "")]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    if (!text || text.trim().length === 0) {
                        console.warn("linux-logos.json is empty");
                        return;
                    }
                    root.linuxLogos = JSON.parse(text);
                    console.log("Loaded", Object.keys(root.linuxLogos).length, "Linux logos");
                } catch (e) {
                    console.warn("Failed to parse linux-logos.json:", e);
                    console.warn("Text received:", text.substring(0, 100));
                }
            }
        }
    }

    // Get hostname
    Process {
        id: hostnameReader
        running: false
        command: ["hostname"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const host = text.trim();
                if (host) {
                    root.hostname = host.charAt(0).toUpperCase() + host.slice(1);
                }
            }
        }
    }

    // Get OS name
    Process {
        id: osReader
        running: false
        command: ["sh", "-c", "grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"'"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const os = text.trim();
                if (os) {
                    root.osName = os;
                    // Only set icon if logos are already loaded
                    if (root.linuxLogos) {
                        const icon = getOsIcon(os);
                        root.osIcon = icon || "";
                    }
                }
            }
        }
    }

     Process {
        id: serviceStatusReader
        running: false

        property string currentService: ""

        function check(serviceName) {
            currentService = serviceName;
            command = ["systemctl", "is-active", serviceName];
            running = true;
        }

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const state = text.trim();

                root.serviceStates[serviceStatusReader.currentService] = state;
                root.serviceStates = Object.assign({}, root.serviceStates);
                // 🔥 ВАЖНО: продолжаем очередь
                root.serviceIndex++;
                root.checkNextService();
            }
        }
    }
    

    function refreshServices() {
        serviceIndex = 0;
        checkNextService();
    }

    function checkNextService() {
        if (serviceIndex >= services.length)
            return;

        const s = services[serviceIndex];
        serviceStatusReader.check(s.name);
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Left panel - Resources
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "transparent"
            radius: Styling.radius(4)

            ColumnLayout {
                anchors.fill: parent
                spacing: 2

                // User info section - Avatar left, info right
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 16

                    // User avatar
                    StyledRect {
                        id: avatarContainer
                        Layout.preferredWidth: 96
                        Layout.preferredHeight: 96
                        radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                        variant: "primary"

                        Image {
                            id: userAvatar
                            anchors.fill: parent
                            anchors.margins: 2
                            source: `file://${Quickshell.env("HOME")}/.face.icon?${GlobalStates.avatarCacheBuster}`
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                            visible: status === Image.Ready

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                                maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle {
                                        width: userAvatar.width
                                        height: userAvatar.height
                                        radius: Config.roundness > 0 ? (height / 2) * (Config.roundness / 16) : 0
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Icons.user
                            font.family: Icons.font
                            font.pixelSize: 48
                            color: Colors.overSurfaceVariant
                            visible: userAvatar.status !== Image.Ready
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: GlobalStates.pickUserAvatar()

                            Rectangle {
                                anchors.fill: parent
                                color: Colors.overSurface
                                opacity: parent.containsMouse ? 0.1 : 0
                                radius: avatarContainer.radius

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                            }
                        }
                    }

                    // User info column
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        // Username
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: Icons.user
                                font.family: Icons.font
                                font.pixelSize: Config.theme.fontSize + 2
                                color: Styling.srItem("overprimary")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    const user = Quickshell.env("USER") || "user";
                                    return user.charAt(0).toUpperCase() + user.slice(1);
                                }
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Medium
                                color: Colors.overBackground
                                elide: Text.ElideRight
                            }
                        }

                        // Hostname
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: Icons.at
                                font.family: Icons.font
                                font.pixelSize: Config.theme.fontSize + 2
                                color: Styling.srItem("overprimary")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!root.hostname)
                                        return "Hostname";
                                    const host = root.hostname.toLowerCase();
                                    return host.charAt(0).toUpperCase() + host.slice(1);
                                }
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Medium
                                color: Colors.overBackground
                                elide: Text.ElideRight
                            }
                        }

                        // OS
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: root.osIcon || (root.linuxLogos ? (root.linuxLogos["Linux"] || "") : "")
                                font.family: "Symbols Nerd Font Mono"
                                font.pixelSize: Config.theme.fontSize + 2
                                color: Styling.srItem("overprimary")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.osName || "Linux"
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Medium
                                color: Colors.overBackground
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // System separator
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 8

                    Separator {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "System"
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(-2)
                        color: Colors.overBackground
                    }

                    Separator {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    contentHeight: resourcesColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: resourcesColumn
                        width: parent.width
                        spacing: 12

                        // CPU
                        Column {
                            width: parent.width
                            spacing: 4

                            ResourceItem {
                                width: parent.width
                                icon: Icons.cpu
                                label: "CPU"
                                value: SystemResources.cpuUsage / 100
                                barColor: Colors.red
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: SystemResources.cpuModel || "CPU"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    color: Colors.overBackground
                                    elide: Text.ElideMiddle
                                }

                                Separator {
                                    Layout.preferredHeight: 2
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: `${Math.round(SystemResources.cpuUsage)}%`
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    font.weight: Font.Medium
                                    color: Colors.overBackground
                                }

                                Text {
                                    visible: SystemResources.cpuTemp >= 0
                                    text: Icons.temperature
                                    font.family: Icons.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    color: Colors.red
                                }

                                Text {
                                    visible: SystemResources.cpuTemp >= 0
                                    text: `${SystemResources.cpuTemp}°`
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    font.weight: Font.Medium
                                    color: Colors.overBackground
                                }
                            }
                        }

                        // RAM
                        Column {
                            width: parent.width
                            spacing: 4

                            ResourceItem {
                                width: parent.width
                                icon: Icons.ram
                                label: "RAM"
                                value: SystemResources.ramUsage / 100
                                barColor: Colors.cyan
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: {
                                        const usedGB = (SystemResources.ramUsed / 1024 / 1024).toFixed(1);
                                        const totalGB = (SystemResources.ramTotal / 1024 / 1024).toFixed(1);
                                        return `${usedGB} GB / ${totalGB} GB`;
                                    }
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    color: Colors.overBackground
                                    elide: Text.ElideMiddle
                                }

                                Separator {
                                    Layout.preferredHeight: 2
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: `${Math.round(SystemResources.ramUsage)}%`
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-2)
                                    font.weight: Font.Medium
                                    color: Colors.overBackground
                                }
                            }
                        }

                        // GPUs (if detected) - show one bar per GPU
                        Repeater {
                            id: gpuRepeater
                            model: SystemResources.gpuDetected ? SystemResources.gpuCount : 0

                            Column {
                                required property int index
                                width: parent.width
                                spacing: 4

                                ResourceItem {
                                    width: parent.width
                                    icon: Icons.gpu
                                    label: {
                                        const name = SystemResources.gpuNames[index] || "";
                                        const vendor = SystemResources.gpuVendors[index] || "";

                                        // If we have a descriptive name, use it
                                        if (name && name !== `${vendor.toUpperCase()} GPU ${index}`) {
                                            return name;
                                        }
                                        // Otherwise show GPU index if multiple, or just "GPU" if single
                                        return SystemResources.gpuCount > 1 ? `GPU ${index}` : "GPU";
                                    }
                                    value: (SystemResources.gpuUsages[index] || 0) / 100
                                    barColor: {
                                        // Color based on vendor
                                        const vendor = SystemResources.gpuVendors[index] || "";
                                        switch (vendor.toLowerCase()) {
                                        case "nvidia":
                                            return Colors.green;
                                        case "amd":
                                            return Colors.red;
                                        case "intel":
                                            return Colors.blue;
                                        default:
                                            return Colors.magenta;
                                        }
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        text: {
                                            const name = SystemResources.gpuNames[index] || "";
                                            return name || "GPU";
                                        }
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        color: Colors.overBackground
                                        elide: Text.ElideMiddle
                                    }

                                    Separator {
                                        Layout.preferredHeight: 2
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: `${Math.round(SystemResources.gpuUsages[index] || 0)}%`
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        font.weight: Font.Medium
                                        color: Colors.overBackground
                                    }

                                    Text {
                                        visible: (SystemResources.gpuTemps[index] ?? -1) >= 0
                                        text: Icons.temperature
                                        font.family: Icons.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        color: {
                                            const vendor = SystemResources.gpuVendors[index] || "";
                                            switch (vendor.toLowerCase()) {
                                            case "nvidia":
                                                return Colors.green;
                                            case "amd":
                                                return Colors.red;
                                            case "intel":
                                                return Colors.blue;
                                            default:
                                                return Colors.magenta;
                                            }
                                        }
                                    }

                                    Text {
                                        visible: (SystemResources.gpuTemps[index] ?? -1) >= 0
                                        text: `${SystemResources.gpuTemps[index]}°`
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        font.weight: Font.Medium
                                        color: Colors.overBackground
                                    }
                                }
                            }
                        }

                        // Disks
                        Repeater {
                            id: diskRepeater
                            model: SystemResources.validDisks

                            Column {
                                required property string modelData
                                width: parent.width
                                spacing: 4

                                ResourceItem {
                                    width: parent.width
                                    icon: {
                                        const diskType = SystemResources.diskTypes[modelData] || "unknown";
                                        switch (diskType) {
                                        case "ssd":
                                            return Icons.ssd;
                                        case "hdd":
                                            return Icons.hdd;
                                        default:
                                            return Icons.disk;
                                        }
                                    }
                                    label: modelData
                                    value: SystemResources.diskUsage[modelData] ? SystemResources.diskUsage[modelData] / 100 : 0
                                    barColor: Colors.yellow
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        text: modelData
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        color: Colors.overBackground
                                        elide: Text.ElideMiddle
                                    }

                                    Separator {
                                        Layout.preferredHeight: 2
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: `${Math.round((SystemResources.diskUsage[modelData] || 0))}%`
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-2)
                                        font.weight: Font.Medium
                                        color: Colors.overBackground
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

       
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.alignment: Qt.AlignTop

            ServiceButton {
                Layout.alignment: Qt.AlignRight
                icon: Icons.stop
                accentColor: Colors.red

                onClicked: {
                    for (let i = 0; i < root.services.length; i++) {
                        const svc = root.services[i];
                        runService(svc.name, "stop");
                    }
                }
            }

            StyledRect {
                variant: "pane"
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: Styling.radius(6)
                color: Colors.surfaceContainer
                border.width: 1
                border.color: Colors.primary

                MouseArea {
                    anchors.fill: parent
                    onClicked: scriptsExpanded = !scriptsExpanded
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    Text {
                        text: Icons.terminal
                        font.family: Icons.font
                        color: Colors.primary
                    }

                    Text {
                        text: "Scripts"
                        Layout.fillWidth: true
                        color: Colors.overSurface
                    }

                    Text {
                        text: scriptsExpanded ? Icons.chevronUp : Icons.chevronDown
                        font.family: Icons.font
                        color: Colors.overSurface
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                visible: scriptsExpanded
                opacity: scriptsExpanded ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                Repeater {
                    model: scripts

                    StyledRect {
                        variant: "pane"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64

                        required property var modelData

                        radius: Styling.radius(6)
                        color: Colors.surfaceContainer
                        border.width: 1
                        border.color: Colors.primary

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        // hover elevation (как у сервисов)
                        Rectangle {
                            anchors.fill: parent
                            radius: Styling.radius(6)
                            color: Colors.surfaceContainerHigh
                            opacity: hover.containsMouse ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 120 }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // 🔹 icon circle (как status у сервисов)
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Colors.primary

                                Text {
                                    anchors.centerIn: parent
                                    text: Icons.terminal
                                    font.family: Icons.font
                                    font.pixelSize: 14
                                    color: Colors.overprimary
                                }
                            }

                            // 🔹 text block
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.label
                                    font.pixelSize: 14
                                    color: Colors.overSurface
                                }

                                Text {
                                    text: modelData.command
                                    font.pixelSize: 11
                                    color: Colors.outline
                                    elide: Text.ElideRight
                                }
                            }

                            // 🔹 spacer (как у сервисов)
                            Item {
                                Layout.fillWidth: true
                            }

                            // 🔹 run button
                            ServiceButton {
                                icon: Icons.play
                                accentColor: Colors.green

                                onClicked: {
                                    Quickshell.execDetached([
                                        "sh",
                                        "-c",
                                        modelData.command
                                    ])
                                }
                            }
                        }
                    }
                }
            }
            
            Repeater {
                model: root.services
                
                StyledRect {
                    variant: "pane"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64

                    radius: Styling.radius(6)

                    required property var modelData

                    color: Colors.surfaceContainer

                    border.width: 1
                    border.color: {
                        state = root.serviceStates[modelData.name] || "unknown";
                        if (state === "active") return Colors.green;
                        if (state === "failed") return Colors.error;
                        return Colors.outlineVariant;
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    // hover elevation
                    Rectangle {
                        anchors.fill: parent
                        radius: Styling.radius(6)
                        color: Colors.surfaceContainerHigh
                        opacity: hover.containsMouse ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // 🔹 Status circle
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16

                            color: {
                                state = root.serviceStates[modelData.name] || "unknown";
                                if (state === "active") return Colors.greenContainer;
                                if (state === "failed") return Colors.errorContainer;
                                return Colors.surfaceVariant;
                            }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    state = root.serviceStates[modelData.name] || "unknown";
                                    if (state === "active") return Icons.check;
                                    if (state === "inactive") return Icons.pause;
                                    if (state === "failed") return Icons.error;
                                    return Icons.help;
                                }
                                font.family: Icons.font
                                font.pixelSize: 14

                                color: {
                                    state = root.serviceStates[modelData.name] || "unknown";
                                    if (state === "active") return Colors.overGreenContainer;
                                    if (state === "failed") return Colors.overErrorContainer;
                                    return Colors.overSurfaceVariant;
                                }
                            }
                        }

                        // 🔹 Text block
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.label
                                font.pixelSize: 14
                                color: Colors.overSurface
                            }

                            Text {
                                text: state = root.serviceStates[modelData.name] || "unknown";
                                font.pixelSize: 11
                                color: Colors.outline
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // 🔹 Buttons
                        RowLayout {
                            spacing: 6

                            ServiceButton {
                                icon: Icons.restart
                                accentColor: Colors.primary
                                onClicked: runService(modelData.name, "restart")
                            }

                            ServiceButton {
                                icon: Icons.stop
                                accentColor: Colors.red
                                onClicked: runService(modelData.name, "stop")
                            }
                        }
                    }
                }
            }
        }
        
    }
}
