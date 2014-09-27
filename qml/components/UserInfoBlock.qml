import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
        width: parent.width
        anchors.right: parent.right
        property var user

        id: userInfoBlock
        height: 100
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.highlightColor
            opacity: 0.3
        }

        Label {
            id: userNameLabel
            anchors.top: userInfoBlock.top
            anchors.topMargin: 15
            anchors.right: userPic.left
            anchors.rightMargin: Theme.paddingSmall
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            text: user ? "<b>" + user.display_name + "</b>" : ""
        }
        Label {
            id: userReputationLabel
            anchors.top: userNameLabel.bottom
            anchors.right: userPic.left
            anchors.rightMargin: Theme.paddingSmall
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeTiny
            text: user ? "Reputation: " + user.reputation : ""
        }
        Image {
            id: userPic
            anchors.top: userInfoBlock.top
            anchors.right: userInfoBlock.right
            width: 100
            height: 100
            smooth: true
            source: user ? user.profile_image : ""
        }
    }
