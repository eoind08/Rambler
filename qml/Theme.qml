pragma Singleton
import QtQuick

QtObject {
  readonly property color bg: "#131418"
  readonly property color sidebarBg: "#15161a"
  readonly property color entryBg: "#202127"
  readonly property color bookHover: "#292a32"
  readonly property color bookSelected: "#353541"
  readonly property color timeline: "#aaa9c8"
  readonly property color divider: "#41414c"
  readonly property color entryText: "#e7e5ed"
  readonly property color editorText: "#b4b2c4"
  readonly property color bookText: "#b4b2c4"
  readonly property int radius: 14
  readonly property string serif: "Georgia"
  readonly property int timeColWidth: 130
  readonly property int lineX: 150
  readonly property int cardLeft: 180
  readonly property int cardPadding: 20
  readonly property int entryGap: 16
  readonly property int pageMargin: 40
  readonly property int dotSize: 12
}
  