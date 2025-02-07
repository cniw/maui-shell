import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Templates 2.15 as T

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.cask 1.0 as Cask

import Zpaces 1.0 as ZP

import QtGraphicalEffects 1.0

T.Pane
{
    id: control
    property ZP.Zpace zpace

    default property alias content: _content.data
    property int radius: 20
    property bool overviewMode : false
    property alias backgroundImage : _img.source
    readonly property bool rise : _dropArea.containsDrag

    Behavior on radius
    {
        NumberAnimation
        {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutInQuad
        }
    }

    background: Item
    {
        id: _bg

        MouseArea
        {
            enabled: !overviewMode
            acceptedButtons: Qt.RightButton
            anchors.fill: parent
            propagateComposedEvents: true
            preventStealing: false
            onClicked:
            {
                _menu.show()
            }

            onPressAndHold:
            {
                _menu.show()
            }
        }

        Item
        {
            id : _bgContainer
            anchors.fill: parent

            Image
            {
                id: _img
                anchors.fill: parent
                anchors.margins: control.rise ? Maui.Style.space.large * 2 : 0
                asynchronous: true
                sourceSize.width: Screen.width
                sourceSize.height: Screen.height
                fillMode: wallpaperSettings.fill? Image.PreserveAspectCrop : Image.PreserveAspectFit
                visible: false

            }
        }

        ColorOverlay
        {
            anchors.fill: _bgContainer
            source: _img
            color: wallpaperSettings.dim && Maui.App.darkMode ? "#80800000" : "transparent"

            layer.enabled: control.radius > 0 || control.rise
            layer.effect: OpacityMask
            {
                maskSource: Rectangle
                {
                    width: _img.width
                    height: _img.height
                    radius: control.radius
                }
            }
        }

        DropShadow
        {
            //            visible: control.rise
            transparentBorder: true
            anchors.fill: _bgContainer
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: Qt.rgba(0,0,0,0.9)
            source: _bgContainer
        }
    }

    contentItem : Item
    {
        id: _container

        Item
        {
            id: _content
            anchors.fill: parent
        }

        TapHandler
        {
            enabled: overviewMode

            //            anchors.fill: parent
            //            propagateComposedEvents: true
            //            preventStealing: false
            onTapped:
            {

                _swipeView.currentIndex = index
                _swipeView.closeOverview()

            }
        }
    }

    WallpaperDialog
    {
        id: _wallpapersDialog
    }

    Maui.ContextualMenu
    {
        id: _menu

        MenuItem
        {
            text: i18n("Wallpaper")
            icon.name: "insert-image"
            onTriggered: _wallpapersDialog.open()
        }

        MenuItem
        {
            text: i18n("Widgets")
            icon.name: "draw-cuboid"
        }
    }

    DropArea
    {
        id: _dropArea

        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                control.zpace.wallpaper = drop.urls[0]
                wallpaperSettings.defaultWallpaper = drop.urls[0]
            }
        }
    }

}
