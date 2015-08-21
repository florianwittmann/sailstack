/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../Api.js" as API
import "../Status.js" as Status
import "../Storage.js" as Storage


Page {
    allowedOrientations: Orientation.All

    property bool dataLoaded : false

    property int pageNr : 1
    id: page




    SilicaListView {
        visible: dataLoaded
        model: sitesModel
        anchors.fill: parent
        header: PageHeader {
            id: header
            title: "Sites"
        }
        delegate: BackgroundItem {
            id: delegate
            height: Theme.itemSizeMedium
                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    height: parent.height
                    width: parent.height
                    fillMode: Image.PreserveAspectFit
                    id: icon
                    source: icon_url
                }
                Label {
                    textFormat: Text.RichText
                    text: name
                    anchors.left: icon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    wrapMode: Text.Wrap
                }
                onClicked: {
                    Status.removeAllTags();
                    API.site = api_site_parameter;
                    API.siteUrl = site_url;
                    API.siteName = name;
                    Storage.set("siteUrl",site_url);
                    Storage.set("siteName",name);
                    Storage.set("site", api_site_parameter);
                    pageStack.replaceAbove(null,Qt.resolvedUrl("QuestionsPage.qml"));
                }


         VerticalScrollDecorator {}
       }



        ListModel {
            id: sitesModel
        }

//##TODO: Invalidates Token, but the qml webview still remember us from cookies##
//        PullDownMenu {
//            MenuItem {
//                 text: "Logout"
//                 onClicked: {
//                     var token = API.access_token;
//                     API.access_token = "";
//                     Storage.set("token","");
//                     API.invalidate_Token(token, pageStack.replaceAbove(null,Qt.resolvedUrl("AuthPage.qml")))

//                 }
//            }
//        }


        Component.onCompleted: {
            if(!Status.sitesLoaded) {
                Status.sites = [];
                getSitesData();
            } else {
                for(var i=0; i<Status.sites.length; i++) {
                    if(Status.sites[i].site_type === "main_site")  {
                        sitesModel.append(Status.sites[i]);
                    }

                }
                dataLoaded=true;
            }
        }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false
        size: BusyIndicatorSize.Large
    }



    function getSitesData() {
        API.get_Sites(pageNr, sitesDataLoaded);
    }

    function sitesDataLoaded(data) {
        dataLoaded = true;
        for(var i=0; i<data.items.length; i++) {
            if(data.items[i].site_type === "main_site")  {
                sitesModel.append(data.items[i]);
                Status.sites.push(data.items[i]);
            }

        }
        if(data.has_more) {
            pageNr = pageNr + 1;
            getSitesData();
        } else {
            Status.sitesLoaded = true;
        }
    }

}





