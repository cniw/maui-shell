import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.cask 1.0 as Cask
import "../../../templates"


StackPage
{
    id: control
    implicitHeight: 400
    title: control.playerName
    property Cask.MprisPlayer player

    property string sourceName: player ? player.serviceName : ""
    property string playerName: player ? player.identity : ""
    property string playerIcon: player ? player.iconName : ""

    readonly property bool isPlaying : state === "Playing"
    property string state : player ? player.status : ""

    readonly property var currentMetadata : player ? player.metadata : undefined

    property string albumArt: currentMetadata ? currentMetadata["mpris:artUrl"] || "" : ""

    property string track: {
        if (!currentMetadata) {
            return ""
        }
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }

    property string artist: {
        if (!currentMetadata) {
            return ""
        }
        var xesamArtist = currentMetadata["xesam:artist"]
        if (!xesamArtist) {
            return "";
        }

        if (typeof xesamArtist == "string") {
            return xesamArtist
        } else {
            return xesamArtist.join(", ")
        }
    }

    property int position: (control.player && control.player.position) || 0
    readonly property real rate: (control.player && control.player.rate) || 1
    readonly property int length: currentMetadata ? currentMetadata["mpris:length"] || 0 : 0

    readonly property bool canSeek: (control.player && control.player.capabilities & Cask.MprisPlayer.CanSeek) || false

    property bool noPlayer: control.players.count === 0

    readonly property string identity: !control.noPlayer ? player.identity || control.sourceName : ""

    readonly property bool canControl: (control.player && control.player.capabilities & Cask.MprisPlayer.CanControl) || false

    readonly property bool canGoPrevious: (control.player && control.player.capabilities & Cask.MprisPlayer.CanGoPrevious) || false

    readonly property bool canGoNext:(control.player && control.player.capabilities & Cask.MprisPlayer.CanGoNext) || false

    readonly property bool canPlay: control.player ? (control.player.capabilities & Cask.MprisPlayer.CanPlay) : false

    readonly property bool canPause: control.player ? (control.player.capabilities & Cask.MprisPlayer.CanPause) : false

    // var instead of bool so we can use "undefined" for "shuffle not supported"
    readonly property var shuffle:  undefined
    readonly property var loopStatus:  undefined

    property bool disablePositionUpdate: false


    headBar.rightContent: [ToolButton
        {
            flat: true
            icon.name: "quickopen"
            onClicked: control.action_open()
        },

        ToolButton
        {
            flat: true
            icon.name: "window-close"
            onClicked: control.action_quit()
        }
    ]

    ColumnLayout
    {
        anchors.fill: parent
        spacing: Maui.Style.space.medium

        Maui.IconItem
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            //            fillMode: Image.PreserveAspectCrop
            imageSource: control.albumArt
            iconSource: control.playerIcon
            //            iconSizeHint: 48
            maskRadius: 10
            //            imageSizeHint: 80
        }

        Slider
        {
            id: seekSlider
            Layout.fillWidth: true
            implicitHeight: visible ? 22 : 0
            from: 0
            value: control.position/control.length
            to: 1
            visible: control.canSeek
            onMoved:
            {
                var service = mpris2Source.serviceForSource(control.sourceName)
                var operation = service.operationDescription("SetPosition")
                operation.microseconds = seekSlider.value*control.length
                service.startOperationCall(operation)

            }

            //            Timer
            //            {
            //                id: seekTimer
            //                interval: 1000
            //                repeat: true
            //                running: control.state === "playing" && interval > 0 && seekSlider.to >= 1000000
            //                onTriggered: {
            //                    // some players don't continuously update the seek slider position via mpris
            //                    // add one second; value in microseconds
            //                    console.log("UPDATE SLIDER")
            //                    if (!seekSlider.pressed)
            //                    {
            //                        disablePositionUpdate = true
            //                        if (seekSlider.value == seekSlider.to) {
            //                            retrievePosition()
            //                        } else {
            //                            seekSlider.value += 1000000
            //                        }
            //                        disablePositionUpdate = false
            //                    }
            //                }
            //            }

        }


        ColumnLayout
        {
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            Layout.alignment: Qt.AlignBottom
            spacing: Maui.Style.space.medium

            Label
            {
                visible: text.length
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                text: control.track
                wrapMode: Text.Wrap
                font.pointSize: Maui.Style.fontSizes.big
                font.bold: true
            }

            Label
            {
                visible: text.length
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

                wrapMode: Text.NoWrap
                text: control.artist
            }

            Row
            {
                spacing: Maui.Style.space.medium
                Layout.alignment: Qt.AlignHCenter
                ToolButton
                {
                    icon.name: "media-skip-backward"
                    enabled: control.canGoPrevious
                    onClicked:
                    {
                        seekSlider.value = 0    // Let the media start from beginning. Bug 362473
                        control.action_previous()
                    }

                }

                ToolButton
                {
                    //                        text: qsTr("Play and pause")
                    enabled: control.canPlay
                    icon.name: control.isPlaying ? "media-playback-pause" : "media-playback-start"
                    onClicked: control.togglePlaying()

                }

                ToolButton
                {
                    icon.name: "media-skip-forward"
                    enabled: control.canGoNext
                    onClicked:
                    {
                        seekSlider.value = 0    // Let the media start from beginning. Bug 362473
                        control.action_next()
                    }

                }
            }
        }
    }

    function togglePlaying() {
        if (control.isPlaying) {
            if (control.canPause) {
                control.action_pause();
            }
        } else {
            if (control.canPlay) {
                control.action_play();
            }
        }
    }
    function action_open() {
        control.player.raise()
    }

    function action_quit() {
        control.player.quit()
    }

    function action_play() {
        control.player.play()
    }

    function action_pause() {
        control.player.pause()
    }

    function action_playPause() {
        control.player.playPause()
    }

    function action_previous() {
        control.player.previous()
    }

    function action_next() {
        control.player.next()
    }

    function action_stop() {
        control.player.stop()
    }


}
