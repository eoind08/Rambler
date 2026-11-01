import QtQuick

Item {
    id: root
    required property string timestamp
    required property string body
    property bool isFirst: false
    property bool isLast: false
    readonly property real dotCenterY: Theme.cardPadding + 11
    implicitHeight: card.height + Theme.entryGap
    Rectangle {
        width: 2
        x: Theme.lineX - width / 2
        y: root.isFirst ? root.dotCenterY : 0
        height: (root.isLast ? root.dotCenterY : root.height) - y
        color: Theme.line
    }
    Rectangle {
        width: Theme.dotSize
        height: Theme.dotSize
        radius: width / 2
        x: Theme.lineX - width / 2
        y: root.dotCenterY - height / 2
        color: Theme.accent
    }
    Text {
        x: 0
        width: Theme.timeColWidth - 16
        y: root.dotCenterY - height / 2
        horizontalAlignment: Text.AlignRight
        text: root.timestamp
        color: Theme.textDim
        font.family: Theme.serif
        font.pixelSize: 15
    }
    Rectangle {
        id: card
        x: Theme.cardLeft
        width: root.width - Theme.cardLeft - Theme.pageMargin
        height: bodyText.implicitHeight + 2 * Theme.cardPadding
        radius: Theme.radius
        color: Theme.surface
        Text {
            id: bodyText
            anchors.fill: parent
            anchors.margins: Theme.cardPadding
            text: root.body
            textFormat: Text.MarkdownText
            wrapMode: Text.Wrap
            color: Theme.textMain
            font.family: Theme.serif
            font.pixelSize: 16
        }
    }
}