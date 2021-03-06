/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4

import "private"
import "templates/private"

/**
 * A drawer specialization that will show a list of actions that are
 * specific of the current page shown by the application
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *  [...]
 * }
 * @endcode
 *
 * @code
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.Page {
 *   [...]
 *     contextualActions: [
 *         Kirigami.Action {
 *             iconName: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             iconName: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *     ]
 *   [...]
 * }
 * @endcode
 *
 * @inherit AbstractDrawer
 */
OverlayDrawer {
    id: root

    /**
     * title: string
     * A title for the action list that will be shown to the user when opens the drawer
     */
    property string title: qsTr("Actions")

    /**
     * actions: list<Action>
     * This can be any type of object that a ListView can accept as model. 
     * It expects items compatible with either QAction or Kirigami Action
     */
    property var actions: pageStack.layers.depth > 1
        ? pageStack.layers.currentItem.contextualActions
        : (pageStack.lastVisibleItem ? pageStack.lastVisibleItem.contextualActions : [])
    // Disable for empty menus or when we have a global toolbar
    enabled: menu.count > 0 &&
            (typeof applicationWindow() === "undefined" || !applicationWindow().pageStack.globalToolBar || applicationWindow().pageStack.lastVisibleItem.globalToolBarStyle !== ApplicationHeaderStyle.ToolBar)
    edge: Qt.application.layoutDirection == Qt.RightToLeft ? Qt.LeftEdge : Qt.RightEdge
    drawerOpen: false

    //list items go to edges, have their own padding
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    handleVisible: applicationWindow == undefined ? false : applicationWindow().controlsVisible

    contentItem: ScrollView {
        //this just to create the attached property
        Theme.inherit: true
        implicitWidth: Units.gridUnit * 20
        ListView {
            id: menu
            interactive: contentHeight > height
            model: {
                if (typeof root.actions == "undefined") {
                    return null;
                }
                if (root.actions.length === 0) {
                    return null;
                } else {
                    return root.actions[0].text !== undefined &&
                        root.actions[0].trigger !== undefined ?
                            root.actions :
                            root.actions[0];
                }
            }
            topMargin: root.handle.y > 0 ? menu.height - menu.contentHeight : 0
            header: Item {
                height: heading.height
                width: menu.width
                Heading {
                    id: heading
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Units.largeSpacing
                    }
                    elide: Text.ElideRight
                    level: 2
                    text: root.title
                }
            }
            delegate: Column {
                width: parent.width
                ContextDrawerActionItem {
                    width: parent.width
                }
                Repeater {
                    model: modelData.hasOwnProperty("expandible") && modelData.expandible ? modelData.children : null
                    delegate: ContextDrawerActionItem {
                        width: parent.width
                        leftPadding: Units.largeSpacing * 2
                        opacity: !root.collapsed
                    }
                }
            }
        }
    }
}
