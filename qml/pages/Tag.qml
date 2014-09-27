import QtQuick 2.0
import Sailfish.Silica 1.0


Rectangle {
    id: tagContainer
    property string tagName
    height: label.height + Theme.paddingSmall*2
    width: label.width + Theme.paddingSmall*2
    color: "transparent"
    Rectangle {

        height: parent.height
        width: parent.width
        color: Theme.secondaryColor
        opacity: 0.2
        radius: 5


    }

    Label {
        anchors.centerIn: tagContainer
        id: label
        text: tagName
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
    }

}


