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
import "../Storage.js" as Storage
import "../Status.js" as Status

Page {
    allowedOrientations: Orientation.All

    property bool dataLoaded : false
    property bool loadingMore : false


    property int pageNr : 1
    id: tagsPage


    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: API.siteName

        }

        SearchField {
            anchors.top: header.bottom
            id: searchField
            width: parent.width

            onTextChanged: {

                searchTagsData();
            }
        }




    SilicaListView {
        id: list
        anchors.top: searchField.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        visible: dataLoaded
        model: tagsModel
        clip: true

        PushUpMenu {
            busy: loadingMore
            MenuItem {
                 text: "Load more"
                 onClicked: {
                     loadingMore = true;
                     pageNr++;
                     getTagsData();
                 }
             }
        }

        delegate: BackgroundItem {

            id: delegate

            Label {
                text: name + " (" + count + "x)"
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeMedium

            }

            onClicked: {
                Status.addTag(name)
                pageStack.replaceAbove(null,Qt.resolvedUrl("QuestionsPage.qml"));
            }
       }

        ListModel {
            id: tagsModel
        }


        VerticalScrollDecorator { }

    }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false
        size: BusyIndicatorSize.Large
    }


    function getTagsData() {
        API.get_Tags(API.site, pageNr, searchField.text, tagsDataLoaded);
    }

    function searchTagsData() {
        pageNr = 1;
        dataLoaded = false;
        API.get_Tags(API.site, pageNr, searchField.text, tagsDataSearched);
    }

    function tagsDataLoaded(data) {
        loadingMore = false;
        dataLoaded = true;
        for(var i=0; i<data.items.length; i++) {
            tagsModel.append(data.items[i]);
        }
    }
    function tagsDataSearched(data) {
        tagsModel.clear();
        loadingMore = false;
        dataLoaded = true;
        for(var i=0; i<data.items.length; i++) {
            tagsModel.append(data.items[i]);
        }
    }

    Component.onCompleted: {
        getTagsData();
    }




}





