/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.3
import bb.data 1.0

Page {
    property int offset: 0
    Container {

        ListView {
            id: listView
            property bool loadingElementVisible: false

            dataModel: ArrayDataModel {
                id: myDataModel
            }

            listItemComponents: [
                ListItemComponent {
                    type: "element"
                    StandardListItem {
                        title: "Page: " + ListItemData.page + "; element: " + ListItemData.element
                    }

                },
                ListItemComponent {
                    type: "loading"
                    CustomListItem {

                        Container {
                            layout: DockLayout {

                            }
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill

                            ActivityIndicator {
                                id: activity
                                preferredHeight: ui.du(4)
                                preferredWidth: ui.du(4)
                                onCreationCompleted: {
                                    activity.start()
                                }
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                            }
                        }
                    }
                }
            ]
            attachedObjects: [
                ListScrollStateHandler {
                    id: listStateHandler
                    property int position
                    onAtEndChanged: {
                        if (atEnd) {
                            console.log("END OF LISTVIEW")
                        }
                    }

                    onFirstVisibleItemChanged: {
                        if (position < firstVisibleItem) {

                            var size = myDataModel.size()
                            var percent = firstVisibleItem / size * 100;

                            if (50 < percent < 75) {
                                dataSource.load();
                            }
                        }
                    }
                }
            ]
            function itemType(data, indexPath) {
                if (data.type == "loading")
                    return "loading";
                return "element";
            }

            function toggleLoadingElement(display) {
                if (display) {
                    if (! listView.loadingElementVisible) {
                        myDataModel.append({
                                type: "loading"
                            });
                        listView.loadingElementVisible = true;
                    }
                } else {
                    if (loadingElementVisible) {
                        myDataModel.removeAt(myDataModel.size() - 1)
                        loadingElementVisible = false;
                    }
                }

            }
        }

    }
    attachedObjects: [
        DataSource {
            id: dataSource
            property int currentPage: 0
            source: "http://adev.si/files/pages.php?page=" + (currentPage + 1)

            onDataLoaded: {
                currentPage ++;
                listView.toggleLoadingElement(false); // if display
                myDataModel.append(data)
            }
            onError: {
                console.log("Error: " + errorMessage)
            }
        }
    ]

    onCreationCompleted: {
        dataSource.load();
    }
}