import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: calcRoot
    visible: false
    anchors.fill: parent
    z: 1500

    property alias expressionText: displayExpr.text
    property alias resultText: displayResult.text

    signal closed()

    function open() {
        shellController.armPermanent(true)
        calcRoot.visible = true
        calcCard.focus = true
    }

    function close() {
        shellController.armPermanent(false)
        calcRoot.visible = false
        calcRoot.closed()
    }

    // Modal Gentle Floating Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        opacity: calcRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: calcRoot.close()
        }
    }

    // Main Calculator Window Card (Bloom Floating Tool Window)
    GlassPanel {
        id: calcCard
        width: 350
        height: 500
        radius: 28
        anchors.centerIn: parent
        scale: calcRoot.visible ? 1.0 : 0.92
        opacity: calcRoot.visible ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        // Keyboard Focus & Event Interception
        focus: calcRoot.visible
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                calcRoot.close()
                event.accepted = true
                return
            }

            var text = event.text
            if (text >= "0" && text <= "9") {
                appendInput(text)
                event.accepted = true
            } else if (text === "+" || text === "-" || text === "*" || text === "/" || text === ".") {
                appendInput(text)
                event.accepted = true
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return || text === "=") {
                calculate()
                event.accepted = true
            } else if (event.key === Qt.Key_Backspace) {
                backspace()
                event.accepted = true
            } else if (text === "c" || text === "C") {
                clearAll()
                event.accepted = true
            }
        }

        // Logic Helpers
        property string currentInput: "0"
        property string fullExpr: ""
        property bool isEvaluated: false

        function appendInput(ch) {
            if (isEvaluated) {
                if ("0123456789.".indexOf(ch) !== -1) {
                    currentInput = (ch === "." ? "0." : ch)
                    fullExpr = ""
                } else {
                    fullExpr = currentInput
                }
                isEvaluated = false
            } else {
                if (currentInput === "0" && ch !== ".") {
                    currentInput = ch
                } else {
                    if (ch === "." && currentInput.indexOf(".") !== -1) return
                    currentInput += ch
                }
            }
            updateDisplay()
        }

        function appendOperator(op) {
            if (isEvaluated) {
                fullExpr = currentInput + " " + op + " "
                currentInput = "0"
                isEvaluated = false
            } else {
                fullExpr += currentInput + " " + op + " "
                currentInput = "0"
            }
            updateDisplay()
        }

        function calculate() {
            var exprToEval = fullExpr + currentInput
            if (exprToEval.trim() === "") return
            
            var res = appLauncherService.evaluateMath(exprToEval)
            if (res.valid) {
                displayExpr.text = exprToEval + " ="
                currentInput = res.result
                displayResult.text = currentInput
                fullExpr = ""
                isEvaluated = true
            } else {
                displayResult.text = "Error"
            }
        }

        function clearAll() {
            currentInput = "0"
            fullExpr = ""
            isEvaluated = false
            updateDisplay()
        }

        function backspace() {
            if (isEvaluated) {
                clearAll()
                return
            }
            if (currentInput.length > 1) {
                currentInput = currentInput.substring(0, currentInput.length - 1)
            } else {
                currentInput = "0"
            }
            updateDisplay()
        }

        function toggleSign() {
            if (currentInput === "0") return
            if (currentInput.startsWith("-")) {
                currentInput = currentInput.substring(1)
            } else {
                currentInput = "-" + currentInput
            }
            updateDisplay()
        }

        function applySpecial(type) {
            var val = parseFloat(currentInput)
            if (isNaN(val)) return

            if (type === "percent") {
                val = val / 100.0
            } else if (type === "sqr") {
                val = val * val
            } else if (type === "sqrt") {
                if (val < 0) { displayResult.text = "Invalid Input"; return }
                val = Math.sqrt(val)
            } else if (type === "recip") {
                if (val === 0) { displayResult.text = "Div by Zero"; return }
                val = 1.0 / val
            }
            currentInput = val.toString()
            updateDisplay()
        }

        function updateDisplay() {
            displayExpr.text = fullExpr
            displayResult.text = currentInput
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header Bar
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    implicitWidth: titleRow.implicitWidth + 16
                    implicitHeight: 28
                    radius: 14
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    border.width: 1
                    border.color: Theme.accent

                    RowLayout {
                        id: titleRow
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "🧮"; font.pixelSize: 13 }
                        Text {
                            text: "Bloom Calculator"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: closeBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#a6adc8"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: closeBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: calcRoot.close()
                    }
                }
            }

            // Screen Display Box
            Rectangle {
                Layout.fillWidth: true
                height: 84
                radius: 16
                color: Qt.rgba(0.06, 0.08, 0.13, 0.8)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 2

                    Text {
                        id: displayExpr
                        text: ""
                        color: "#9399b2"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignRight
                        elide: Text.ElideLeft
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        id: displayResult
                        text: "0"
                        color: "#cdd6f4"
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignRight
                        elide: Text.ElideLeft
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // Keypad Grid Layout
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 4
                rowSpacing: 6
                columnSpacing: 6

                // Row 1: %, CE, C, Backspace
                CalcBtn { label: "%"; colorType: "func"; onClicked: calcCard.applySpecial("percent") }
                CalcBtn { label: "CE"; colorType: "func"; onClicked: { calcCard.currentInput = "0"; calcCard.updateDisplay() } }
                CalcBtn { label: "C"; colorType: "danger"; onClicked: calcCard.clearAll() }
                CalcBtn { label: "⌫"; colorType: "func"; onClicked: calcCard.backspace() }

                // Row 2: 1/x, x², √x, ÷
                CalcBtn { label: "1/x"; colorType: "func"; onClicked: calcCard.applySpecial("recip") }
                CalcBtn { label: "x²"; colorType: "func"; onClicked: calcCard.applySpecial("sqr") }
                CalcBtn { label: "√x"; colorType: "func"; onClicked: calcCard.applySpecial("sqrt") }
                CalcBtn { label: "÷"; colorType: "op"; onClicked: calcCard.appendOperator("/") }

                // Row 3: 7, 8, 9, ×
                CalcBtn { label: "7"; onClicked: calcCard.appendInput("7") }
                CalcBtn { label: "8"; onClicked: calcCard.appendInput("8") }
                CalcBtn { label: "9"; onClicked: calcCard.appendInput("9") }
                CalcBtn { label: "×"; colorType: "op"; onClicked: calcCard.appendOperator("*") }

                // Row 4: 4, 5, 6, -
                CalcBtn { label: "4"; onClicked: calcCard.appendInput("4") }
                CalcBtn { label: "5"; onClicked: calcCard.appendInput("5") }
                CalcBtn { label: "6"; onClicked: calcCard.appendInput("6") }
                CalcBtn { label: "-"; colorType: "op"; onClicked: calcCard.appendOperator("-") }

                // Row 5: 1, 2, 3, +
                CalcBtn { label: "1"; onClicked: calcCard.appendInput("1") }
                CalcBtn { label: "2"; onClicked: calcCard.appendInput("2") }
                CalcBtn { label: "3"; onClicked: calcCard.appendInput("3") }
                CalcBtn { label: "+"; colorType: "op"; onClicked: calcCard.appendOperator("+") }

                // Row 6: +/-, 0, ., =
                CalcBtn { label: "+/-"; onClicked: calcCard.toggleSign() }
                CalcBtn { label: "0"; onClicked: calcCard.appendInput("0") }
                CalcBtn { label: "."; onClicked: calcCard.appendInput(".") }
                CalcBtn { label: "="; colorType: "accent"; onClicked: calcCard.calculate() }
            }
        }
    }

    // Helper Component for Buttons
    component CalcBtn: Rectangle {
        property string label: ""
        property string colorType: "num" // "num", "op", "func", "accent", "danger"
        signal clicked()

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 10

        color: {
            if (btnMouse.pressed) return Qt.rgba(1, 1, 1, 0.25)
            if (btnMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.15)
            if (colorType === "accent") return Theme.accent
            if (colorType === "op") return Qt.rgba(0.25, 0.28, 0.4, 0.6)
            if (colorType === "danger") return Qt.rgba(0.9, 0.3, 0.35, 0.4)
            if (colorType === "func") return Qt.rgba(0.18, 0.2, 0.3, 0.5)
            return Qt.rgba(0.14, 0.16, 0.24, 0.6)
        }

        border.width: 1
        border.color: colorType === "accent" ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.05)

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: parent.colorType === "accent" ? "#11111b" : "#cdd6f4"
            font.pixelSize: 15
            font.weight: parent.colorType === "accent" || parent.colorType === "op" ? Font.Bold : Font.Normal
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }
}
