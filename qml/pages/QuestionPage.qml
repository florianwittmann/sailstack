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
  ANY DIRECT, INDIRECT, INCIDTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
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
import "../Helper.js" as Helper
import "../components"


Page {

    property bool dataLoaded : false

    property int question_id : 0
    id: questionPage

    property var currentQuestion


    SilicaFlickable {
        visible: dataLoaded


        anchors.fill: parent
        contentWidth: parent.width;
        contentHeight: col.height + pageHeader.height + 40

        PullDownMenu {
            MenuItem {
                 text: "Open in browser"
                 onClicked: {
                     Qt.openUrlExternally(API.siteUrl + "/questions/" + question_id )
                 }
             }
        }


        PageHeader {
            id: pageHeader
            width: parent.width
            anchors.right: parent.right

            UserInfoBlock {
                width: parent.width

                user: currentQuestion? currentQuestion.owner : {}
            }
        }


        Column {
            spacing: 5
            id: col
            width: parent.width
            anchors.top: pageHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            Label {
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                id: questionTitle
                text: currentQuestion ? currentQuestion.title : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor

                anchors.right: parent.right
                anchors.left: parent.left

            }

            Row {
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.left: parent.left

                spacing: 6
                Repeater {
                    model: currentQuestion  ? currentQuestion.tags : []
                    Tag {
                        tagName: modelData
                    }
                }
            }

            Label {
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.left: parent.left


                id: question
                text: currentQuestion ? Helper.prettyRichText(currentQuestion.body) : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                onLinkActivated: Qt.openUrlExternally(link)
            }

            property bool loadingComments : false;

            Button {
                text: "Load Comments"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    visible = false
                    getQuestionCommentsData();
                }

                function getQuestionCommentsData() {
                    parent.loadingComments = true;
                    API.get_CommentsForQuestion(API.site, question_id, questionCommentsDataLoaded);
                }

                function questionCommentsDataLoaded(data) {
                    for(var i=0; i<data.items.length; i++) {
                        questionCommentsModel.append(data.items[i]);
                    }
                    parent.loadingComments = false;
                }
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: parent.loadingComments
                visible: parent.loadingComments
            }

            Repeater {
                width: parent.width
                model: questionCommentsModel
                CommentElement {
                }
            }

             ListModel {
                id: questionCommentsModel
            }



            Repeater {
                width: parent.width

                model: answersModel

                Rectangle {
                    height: answerUser.height + answerLabel.height + colAnswerComments.height + 50
                    width: parent.width
                    color: "transparent"


                    UserInfoBlock {
                        anchors.top: parent.top
                        anchors.topMargin: 50
                        id: answerUser
                        user: owner
                    }
                     Label {
                         id: scoreLabel
                         anchors.top: parent.top
                         anchors.topMargin: 65
                         anchors.left: parent.left
                         anchors.leftMargin: Theme.paddingLarge
                         text: score
                         font.pixelSize: Theme.fontSizeLarge
                    }

                     Rectangle {
                         visible: is_accepted
                         anchors.left: scoreLabel.right
                         anchors.leftMargin: Theme.paddingLarge
                         anchors.top: parent.top
                         anchors.topMargin: 65
                         color: "transparent"
                         height: 60
                         width: 60
                         Rectangle {
                             anchors.fill: parent
                             radius: 10
                             color: Theme.highlightColor
                             opacity: 0.4
                         }

                         Image {
                             anchors.centerIn: parent
                             source: "../images/accepted_answer.png"
                         }
                     }


                    Label {
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.rightMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        id: answerLabel
                        anchors.top: answerUser.bottom
                        text: Helper.prettyRichText(body)
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.RichText
                        font.pixelSize: Theme.fontSizeSmall
                        width: parent.width
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                    Column {
                        id: colAnswerComments
                        anchors.top: answerLabel.bottom
                        anchors.topMargin: 5
                        property bool loadingAnswerComments : false;
                        anchors.right: parent.right
                        anchors.left: parent.left

                        Button {
                            text: "Load Comments"
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                visible = false
                                getAnswerCommentsData();
                            }

                            function getAnswerCommentsData() {
                                parent.loadingAnswerComments = true;
                                API.get_CommentsForAnswer(API.site, answer_id, answerCommentsDataLoaded);
                            }

                            function answerCommentsDataLoaded(data) {
                                for(var i=0; i<data.items.length; i++) {
                                    answerCommentsModel.append(data.items[i]);
                                }
                                parent.loadingAnswerComments = false;
                            }
                        }

                        BusyIndicator {
                            anchors.horizontalCenter: parent.horizontalCenter
                            running: parent.loadingAnswerComments
                            visible: parent.loadingAnswerComments
                        }

                        Repeater {
                            width: parent.width
                            model: answerCommentsModel
                            CommentElement {
                            }
                        }

                         ListModel {
                            id: answerCommentsModel
                        }
                    }


                }


            }
        }


        Component.onCompleted: {
            getQuestionData();
        }
        VerticalScrollDecorator { }

    }
    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false
        size: BusyIndicatorSize.Large
    }


    ListModel {
        id: answersModel
    }


    function getQuestionData() {
        API.get_Question(API.site, question_id, questionDataLoaded);
    }

    function questionDataLoaded(data) {
        dataLoaded =true;
        currentQuestion = data.items[0];
        getAnswersData();
    }

    function getAnswersData() {
        API.get_Answers(API.site, question_id, answersDataLoaded);
    }

    function answersDataLoaded(data) {
        for(var i=0; i<data.items.length; i++) {
            answersModel.append(data.items[i]);
        }
    }


}





