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
import "../Helper.js" as Helper


Page {
    allowedOrientations: Orientation.All

    property bool searchIsVisible : true
    property bool dataLoaded : false
    property bool loadingMore : false

    property string searchText : ""
    property string sortBy : "activity"

    property var refreshTags : function() {
        refreshActiveTags();
    }

    property int pageNr : 1
    id: questionsPage

    property var currentlySearchInterval;


    SilicaListView {
        currentIndex: -1
        opacity: 1
        id: listView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: questionsModel
        clip: true


        header: Column {
            id: headerCol
            width: parent.width
            PageHeader {
                id: header
                title: API.siteName
                height: Theme.itemSizeSmall
            }
            Label {
                text: "sort by " + sortBy
                anchors.rightMargin: Theme.paddingLarge
                anchors.right: parent.right
                height: Theme.itemSizeSmall


                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        panel.show();
                        animationShow.start();

                    }
                }
                PropertyAnimation {id: animationShow; target: listView; property: "opacity"; to: 0.2 }
            }



            Row {
                id:tagsBar

                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.left: parent.left

                spacing: 6
                Repeater {
                    model: activeTags
                    Tag {
                        tagName: name
                    }
                }
            }
            SearchField {
                height : searchIsVisible ? Theme.itemSizeMedium : 0
                id: searchField
                visible: searchIsVisible
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.left: parent.left
                onTextChanged: {
                    searchText = text;
                    pageNr = 1;
                    questionsModel.clear();
                    dataLoaded = false;

                    timerSearchQuestions.restart();

                }
            }
        }


        PullDownMenu {
            MenuItem {
                 text: "Change Site"
                 onClicked: {
                     pageStack.push(Qt.resolvedUrl("SitesPage.qml"))
                 }
             }
            MenuItem {
                 text: "Remove all Tags"
                 visible: activeTags.count > 0
                 onClicked: {
                     activeTags.clear();
                     pageNr = 1;
                     Status.removeAllTags();
                     questionsModel.clear();
                     dataLoaded = false;
                     searchText.trim() === "" ? getQuestionsData() : searchQuestionsData();
                 }
             }
            MenuItem {
                 text: "Add Tag"
                 onClicked: {
                     pageStack.push(Qt.resolvedUrl("TagsPage.qml"))
                 }
             }
            MenuItem {
                text: searchIsVisible ? "Hide search" : "Show search"
                 onClicked: {
                     searchIsVisible = !searchIsVisible;
                     Storage.set("questionsSearchIsVisible",searchIsVisible ? "1" : "0");
                 }
             }
        }
        PushUpMenu {
            busy: loadingMore
            MenuItem {
                 text: "Load more"
                 onClicked: {
                     loadingMore = true;
                     pageNr++;
                     if(searchText === "") {
                         getQuestionsData();
                     } else {
                         searchQuestionsData();
                     }


                 }
             }
        }

        delegate: BackgroundItem {
            visible: dataLoaded

            id: delegate
            height: Math.max(Theme.itemSizeMedium,questionTitle.height + stats.height + 2* Theme.paddingSmall)

            Label {
                id: questionTitle
                text: title
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
            }
            Row {
                id: stats
                anchors.top: questionTitle.bottom
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                spacing: 6
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor

                    text: "score: " + score
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: is_answered ? Theme.highlightColor : Theme.secondaryColor

                    text: "answers: " + answer_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor

                    text:  "views: " + view_count
                }

                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor

                    text:  "(" + formatShortLocaleTime(creation_date*1000) + ")"

                }


            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("QuestionPage.qml"), {question_id: question_id})
            }
       }

        ListModel {
            id: questionsModel
        }


        VerticalScrollDecorator { }


    }
    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false
        size: BusyIndicatorSize.Large
    }


    function getQuestionsData() {
        API.get_Questions(API.site, pageNr,sortBy,Status.getTagsString(), questionsDataLoaded);
    }

    function questionsDataLoaded(data) {
        if(data === undefined || data.items === undefined) {
            console.log("ERROR!")
            Helper.output(Helper.serialize(data));
            return;
        }
        loadingMore = false;
        dataLoaded = true;
        for(var i=0; i<data.items.length; i++) {
            questionsModel.append(data.items[i]);
        }
    }

    Timer {
        id: timerSearchQuestions
        interval: 600
        running: false
        repeat: false
        onTriggered: searchText.trim() === "" ? getQuestionsData() : searchQuestionsData()
    }


    function searchQuestionsData() {
        API.search_Questions(API.site, pageNr,sortBy,Status.getTagsString(),searchText, questionsDataLoaded);

    }




    Component.onCompleted: {
        sortBy = sortByModel.get(parseInt(Storage.get("questionsSortBy","0"))).sortByText
        searchIsVisible = Storage.get("questionsSearchIsVisible","0") === "1"

        getQuestionsData();
        refreshActiveTags();
    }

    function refreshActiveTags() {
        activeTags.clear();
        for(var i=0; i< Status.choosedTags.length; i++) {
            activeTags.append({"name" : Status.choosedTags[i]});
        }
    }

    ListModel {
        id: activeTags
    }

    ListModel {
        id: sortByModel
        ListElement { sortByText: "activity" }
        ListElement { sortByText: "creation" }
        ListElement { sortByText: "votes" }
        ListElement { sortByText: "hot" }
    }

    DockedPanel {
        id: panel

        width: parent.width
        height:  Theme.itemSizeSmall * 4
        dock: Dock.Top

        SilicaListView {

            id:  listSortBy
            width: parent.width
            height:  Theme.itemSizeSmall * 4
            onHeightChanged: {
                listView.scrollToTop();
            }

            model: sortByModel
            delegate: BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity: 0.3
                    visible : sortBy === sortByText
                }

                Row {
                     anchors.centerIn: parent
                     Label {
                        text: "sort by "
                        color: Theme.secondaryColor
                     }
                    Label {
                        text: sortByText

                    }
                }



                onClicked: {
                    if(!dataLoaded) {
                        return;
                    }
                    sortBy = sortByText;
                    questionsModel.clear();
                    pageNr = 1;
                    dataLoaded = false;
                    searchText === "" ? getQuestionsData() : searchQuestionsData();
                    panel.hide();
                    Storage.set("questionsSortBy",index.toString());
                    animationHide.start();

                }
            }

        }


    }
    MouseArea {
        anchors.top: panel.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: panel.open
        onClicked: {
            panel.hide();
            animationHide.start();
        }
    }

    PropertyAnimation {id: animationHide; target: listView; property: "opacity"; to: 1 }


    function formatShortLocaleTime(d) {
        return new Date(d).toLocaleString(Qt.locale(),Locale.ShortFormat);
    }

}





