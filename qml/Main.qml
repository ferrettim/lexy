import QtQuick 2.9
import Morph.Web 0.1
import QtWebEngine 1.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.UnityWebApps 0.1 as UnityWebApps
import Ubuntu.Content 1.1
import QtMultimedia 5.8
import QtSystemInfo 5.0
import "components"
import "actions" as Actions
import "."

MainView {
    id: root
    objectName: "mainView"
    ScreenSaver { screenSaverEnabled: false }
    theme.name: "Ubuntu.Components.Themes.Ambiance"

    focus: true

    anchors {
        fill: parent
    }

    applicationName: "lexy.alexa"
    anchorToKeyboard: true
    automaticOrientation: true
    property bool blockOpenExternalUrls: false
    property bool runningLocalApplication: false
    property bool openExternalUrlInOverlay: true
    property bool popupBlockerEnabled: true

    Page {
        id: page
        header: Rectangle {
            color: "#000000"
            width: parent.width
            height: units.dp(.5)
            z: 1
        }
        anchors {
            fill: parent
            bottom: parent.bottom
        }

        WebEngineView {
            id: webview

            WebEngineProfile {
            id: webContext

            property alias userAgent: webContext.httpUserAgent
            property alias dataPath: webContext.persistentStoragePath

            dataPath: dataLocation

            userAgent: "Mozilla/5.0 (Linux; U; Android 4.1.1; es-; AVA-V470 Build/GRK39F) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"

            persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
            }

            anchors {
                fill: parent
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(0)
                bottomMargin: units.gu(6)
            }
                zoomFactor: 2.0
                url: "https://alexa.amazon.com"

                userScripts: [
                    WebEngineScript {
                       name: "oxide://lexy-no-omniprompt/"
                       sourceUrl: Qt.resolvedUrl("js/lexy-no-omniprompt.js")
                       runOnSubframes: true
           }
        ]

            onFileDialogRequested: function(request) {

            switch (request.mode)
        {
            case FileDialogRequest.FileModeOpen:
                request.accepted = true;
                var fileDialogSingle = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
                fileDialogSingle.allowMultipleFiles = false;
                fileDialogSingle.accept.connect(request.dialogAccept);
                fileDialogSingle.reject.connect(request.dialogReject);
                break;

            case FileDialogRequest.FileModeOpenMultiple:
                request.accepted = true;
                var fileDialogMultiple = PopupUtils.open(Qt.resolvedUrl("ContentPickerDialog.qml"));
                fileDialogMultiple.allowMultipleFiles = true;
                fileDialogMultiple.accept.connect(request.dialogAccept);
                fileDialogMultiple.reject.connect(request.dialogReject);
                break;

            case FilealogRequest.FileModeUploadFolder:
            case FileDialogRequest.FileModeSave:
                request.accepted = false;
                break;
            }

        }

        onNewViewRequested: function(request) {
                Qt.openUrlExternally(request.requestedUrl);
            }

        Loader {
            anchors {
                fill: popupWebview
            }
            active: webProcessMonitor.crashed || (webProcessMonitor.killed && !popupWebview.currentWebview.loading)
            sourceComponent: SadPage {
                webview: popupWebview
                objectName: "overlaySadPage"
            }
            WebProcessMonitor {
                id: webProcessMonitor
                webview: popupWebview
            }
            asynchronous: true
          }
       }

            Loader {
                id: contentHandlerLoader
                source: "ContentHandler.qml"
                asynchronous: true
            }

            Loader {
                id: downloadLoader
                source: "Downloader.qml"
                asynchronous: true
            }

            Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }

            Loader {
                id: downloadDialogLoader
                source: "ContentDownloadDialog.qml"
                asynchronous: true
            }

     BottomMenu {
        id: bottomMenu
        width: parent.width
     }
   }
 }
