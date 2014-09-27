import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Helper.js" as Helper

Rectangle {
    height: questionCommentLabel.height + commentHeader.height
    width: parent.width
    color: "transparent"

    Label {
        id: commentHeader
        text: "Comment by " + owner.display_name
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        anchors.right: parent.right
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
    }

    Label {
        anchors.top: commentHeader.bottom
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.left: parent.left
        id: questionCommentLabel
        text: Helper.prettyRichText(body)
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText
        font.pixelSize: Theme.fontSizeTiny
        width: parent.width
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
