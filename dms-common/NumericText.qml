import QtQuick
import qs.Common
import qs.Widgets

StyledText {
    id: root

    property string reserveText: ""
    readonly property real reservedWidth: reserveText !== "" ? Math.max(contentWidth, reserveMetrics.width) : contentWidth

    isMonospace: true
    wrapMode: Text.NoWrap

    StyledTextMetrics {
        id: reserveMetrics
        isMonospace: root.isMonospace
        font: root.font
        text: root.reserveText
    }
}
