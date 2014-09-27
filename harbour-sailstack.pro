# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailstack

CONFIG += sailfishapp

SOURCES += src/harbour-sailstack.cpp

OTHER_FILES += qml/harbour-sailstack.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-sailstack.spec \
    rpm/harbour-sailstack.yaml \
    translations/*.ts \
    harbour-sailstack.desktop \
    qml/pages/AuthPage.qml \
    qml/Status.js \
    qml/Api.js \
    qml/pages/SitesPage.qml \
    qml/pages/QuestionsPage.qml \
    qml/pages/QuestionPage.qml \
    qml/Storage.js \
    qml/pages/Tag.qml \
    qml/components/UserInfoBlock.qml \
    qml/components/CommentElement.qml \
    qml/Helper.js \
    qml/pages/TagsPage.qml \
    qml/images/accepted_answer.png \
    LICENSE \
    Changelog

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-sailstack-de.ts

RESOURCES +=

