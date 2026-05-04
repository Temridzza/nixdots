pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

Item {
    id: root

    signal valueChanged(real newValue)
    signal iconClicked

    property string icon: ""

    // 🔥 диапазон
    property real from: 0
    property real to: 150

    // 🔥 реальное значение
    property real sliderValue: 0

    property color progressColor: Styling.srItem("overprimary")
    property bool wavy: false
    property real wavyAmplitude: 0.8
    property real wavyFrequency: 8
    property real iconRotation: 0
    property real iconScale: 1

    // 🔥 нормализация
    function normalizedValue() {
        return (sliderValue - from) / (to - from);
    }

    function valueFromPosition(mouseX) {
        const norm = Math.max(0, Math.min(1, mouseX / sliderContainer.width));
        return from + norm * (to - from);
    }

    // --- анимации (без изменений) ---
    property real _animatedWavyAmplitude: wavyAmplitude
    property real _animatedWavyFrequency: wavyFrequency
    property real _animatedIconRotation: iconRotation
    property real _animatedIconScale: iconScale

    Behavior on _animatedWavyAmplitude {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutQuart }
    }
    Behavior on _animatedWavyFrequency {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutQuart }
    }
    Behavior on _animatedIconRotation {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }
    Behavior on _animatedIconScale {
        enabled: Config.animDuration > 0
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    onWavyAmplitudeChanged: _animatedWavyAmplitude = wavyAmplitude
    onWavyFrequencyChanged: _animatedWavyFrequency = wavyFrequency
    onIconRotationChanged: _animatedIconRotation = iconRotation
    onIconScaleChanged: _animatedIconScale = iconScale

    implicitHeight: 36
    implicitWidth: 200

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // --- иконка ---
        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: iconText
                anchors.centerIn: parent
                text: root.icon
                font.family: Icons.font
                font.pixelSize: 18
                color: iconMouseArea.containsMouse ? Styling.srItem("overprimary") : Colors.overBackground
                rotation: root._animatedIconRotation
                scale: root._animatedIconScale

                Behavior on color {
                    enabled: Config.animDuration > 0
                    ColorAnimation { duration: Config.animDuration / 2 }
                }
            }

            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        // --- слайдер ---
        Item {
            id: sliderContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter

            property real animatedProgress: root.normalizedValue()

            Behavior on animatedProgress {
                enabled: Config.animDuration > 0
                NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutQuart }
            }

            // фон
            Rectangle {
                anchors.left: dragHandle.right
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: Styling.radius(0) / 4
                color: Colors.surfaceBright
            }

            // прогресс
            CarouselProgress {
                anchors.left: parent.left
                anchors.right: dragHandle.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                frequency: root._animatedWavyFrequency
                color: root.progressColor
                amplitudeMultiplier: root._animatedWavyAmplitude
                height: 32
                lineWidth: 4
                fullLength: sliderContainer.width
                visible: root.wavy
                active: true
                z: 1
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: dragHandle.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: Styling.radius(0) / 4
                color: root.progressColor
                visible: !root.wavy
                z: 1
            }

            // 🔥 ползунок
            Rectangle {
                id: dragHandle
                anchors.verticalCenter: parent.verticalCenter
                x: sliderContainer.width * sliderContainer.animatedProgress - width / 2
                width: mouseArea.pressed ? 2 : 4
                height: mouseArea.pressed ? 20 : 16
                radius: Styling.radius(0)
                color: Colors.overBackground
                z: 2

                Behavior on width {
                    enabled: Config.animDuration > 0
                    NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutQuart }
                }
                Behavior on height {
                    enabled: Config.animDuration > 0
                    NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutQuart }
                }
            }

            // tooltip
            StyledToolTip {
                tooltipText: `${Math.round(root.sliderValue)}%`
                visible: mouseArea.pressed
                x: dragHandle.x + dragHandle.width / 2 - width / 2
                y: dragHandle.y - height - 5
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                onPressed: mouse => {
                    root.sliderValue = root.valueFromPosition(mouse.x);
                    root.valueChanged(root.sliderValue);
                }

                onPositionChanged: mouse => {
                    if (pressed) {
                        root.sliderValue = root.valueFromPosition(mouse.x);
                        root.valueChanged(root.sliderValue);
                    }
                }

                onWheel: wheel => {
                    const step = 5;

                    if (wheel.angleDelta.y > 0) {
                        root.sliderValue = Math.min(root.to, root.sliderValue + step);
                    } else {
                        root.sliderValue = Math.max(root.from, root.sliderValue - step);
                    }

                    root.valueChanged(root.sliderValue);
                }
            }
        }
    }
}