import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Api.js" as API
import "../Storage.js" as Storage


Page {

    property string client_id: "3531"
    property string scope: "read_inbox,write_access,no_expiry,private_info"
    property string redirect_uri : "https://stackexchange.com/oauth/login_success"
    property string auth_url : "https://stackexchange.com/oauth/dialog?client_id=" + client_id + "&scope=" + scope + "&redirect_uri=" + redirect_uri
    property bool showWebview : false

    Column {
        id: col
        spacing: 15
        visible: !showWebview
        anchors.fill: parent
        PageHeader {
            title: "SailStack"
        }
        Image {
            source: "../images/header_logo.png"
        }

        Label {
            text: "Welcome to SailStack, an unoffical StackExchange client for Sailfish. Please press 'continue' to login or create a StackExchange account."
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            color: Theme.highlightColor
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Continue"
            onClicked : {
                webview.url = auth_url;
                webview.visible = true;
                showWebview = true;
            }
        }
    }

    SilicaWebView {
        id: webview
        visible: showWebview

        anchors.fill: parent

        onUrlChanged: {
            if(url.toString().indexOf(redirect_uri)==0) {
                //Success
                console.log(url);
                var extracted = url.toString().substring(redirect_uri.length + 14);
                var posExpire = extracted.indexOf("&expires=");
                if(posExpire != -1) {
                    extracted = extracted.slice(0,posExpire)
                }
                API.access_token = extracted
                authentificated();
            } else {
                console.log(url);
            }
        }

    }

    function authentificated() {
        Storage.set("token",API.access_token);
        var site = Storage.get("site","");
        var siteUrl = Storage.get("siteUrl","");
        var siteName = Storage.get("siteName","");
        if(site ===  "" || siteUrl ===  "" || siteName ===  "") {
            pageStack.replace(Qt.resolvedUrl("SitesPage.qml"))
        } else {
            API.site = site;
            API.siteName = siteName;
            API.siteUrl = siteUrl;
            pageStack.replace(Qt.resolvedUrl("QuestionsPage.qml"))
        }


    }

}
