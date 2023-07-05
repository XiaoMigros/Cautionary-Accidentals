//==============================================
//  Cautionary Accidentals v4.0
//  https://github.com/XiaoMigros/Cautionary-Accidentals
//  Copyright (C)2023 XiaoMigros
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//==============================================

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import MuseScore 3.0
import MuseScore.UiComponents 1.0 as MU
import MuseScore.Ui 1.0
import Qt.labs.settings 1.0
import "assets"
import "assets/defaultsettings.js" as DSettings

MuseScore {
	version: "4.0-beta"
	title: qsTr("Configure Cautionary Accidentals")
	categoryCode: "composing-arranging-tools"
	thumbnailName: "assets/logo.png"
	description: qsTr("Choose when to add cautionary accidentals to your scores, and how they look.")
	requiresScore: false
	
	readonly property int maxSpace: 15
	readonly property int regSpace: 10
	readonly property int minSpace: 5
	
	//TODO:
	//move more stuff to separate components (grace note checkboxes)
	//fix keysig setting checkboxes
	
	onRun: mainWindow.show()
	
	ApplicationWindow {
		id: mainWindow
		height: 400
		width: 480
		background: Rectangle {color: ui.theme.backgroundSecondaryColor}
		title: qsTr("Cautionary Accidentals: Settings")
		MU.StyledFlickable {
			id: flickable
			anchors.fill: parent
			focus: true
			contentWidth: contentItem.childrenRect.width + 2 * mainColumn.x
			contentHeight: contentItem.childrenRect.height + 2 * mainColumn.y
			readonly property bool isScrollable: contentHeight > height
			Keys.onUpPressed: scrollBar.decrease()
			Keys.onDownPressed: scrollBar.increase()
			ScrollBar.vertical: MU.StyledScrollBar {id: scrollBar}
			ColumnLayout {
				id: mainColumn
				spacing: 0
				
				ColumnLayout {
					spacing: regSpace
					Layout.margins: regSpace
					
					MenuButton {
						id: generalButton
						title: qsTr("General Settings")
						isExpanded: true
					}
					ColumnLayout {
						spacing: maxSpace
						Layout.leftMargin: regSpace
						visible: generalButton.isExpanded
						
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting0Button
								title: qsTr("Double accidentals")
							}
							StyledFrame {
								visible: setting0Button.isExpanded
								
								ColumnLayout {
									anchors.margins: regSpace
									spacing: regSpace
									
									DynamicImage {id: setting0Image}
									
									MU.CheckBox {
										id: setting0Box
										Layout.leftMargin: regSpace
										text: qsTr("Use natural flats/sharps when cancelling double accidentals")
										onClicked: {checked = !checked; updatesetting0Img()}
										signal setv(bool checked)
										onSetv: function(value) {checked = value; updatesetting0Img()}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting6Button
								title: qsTr("Restating grace note accidentals")
							}
							StyledFrame {
								visible: setting6Button.isExpanded
								
								ColumnLayout {
									anchors.margins: regSpace
									spacing: regSpace
									
									DynamicImage {id: setting6Image}
									
									ColumnLayout {
										spacing: minSpace
										width: parent.width
										
										StyledLabel {text: qsTr("In same staff:")}
										
										AddAccItem {
											id: setting6aAcc
											Layout.leftMargin: regSpace
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.leftMargin - Layout.rightMargin
											onClicked: {updatesetting6Img()}
											onActivated: {updatesetting6Img()}
										}
									}
									
									ColumnLayout {
										spacing: minSpace
										width: parent.width
											
										StyledLabel {text: qsTr("In different staves of same instrument:")}
										
										AddAccItem {
											id: setting6bAcc
											Layout.leftMargin: regSpace
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.leftMargin - Layout.rightMargin
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting9aButton
								title: qsTr("Cancelling in the same measure")
							}
							StyledFrame {
								visible: setting9aButton.isExpanded
								
								ColumnLayout {
									anchors.margins: regSpace
									spacing: regSpace
									
									DynamicImage {id: setting9aImage}
									
									CancelModeItem {
										id: setting9aCancel
										onClicked: updatesetting9aImg()
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting9bButton
								title: qsTr("Cancelling in the next measure")
							}
							StyledFrame {
								visible: setting9bButton.isExpanded
								
								ColumnLayout {
									anchors.margins: regSpace
									spacing: regSpace
									
									DynamicImage {id: setting9bImage}
									
									CancelModeItem {
										id: setting9bCancel
										onClicked: updatesetting9bImg()
									}
								}
							}
						}
					}
				}
				MU.SeparatorLine {width: mainWindow.width}
				ColumnLayout {
					spacing: regSpace
					Layout.margins: regSpace
					
					MenuButton {
						id: sameStaffButton
						title: qsTr("Notes in the same staff")
					}
					ColumnLayout {
						spacing: maxSpace
						Layout.leftMargin: regSpace
						visible: sameStaffButton.isExpanded
						
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting4aButton
								title: qsTr("Notes in the same octave in the next measure")
							}
							StyledFrame {
								visible: setting4aButton.isExpanded
								
								ColumnLayout {
									id: setting4aColumn
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting4aAcc.checked
									
									DynamicImage {id: setting4aImage}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting4aAcc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting4aImg()}
											onActivated: {updatesetting4aImg()}
										}
										MU.CheckBox {
											id: setting4a3Box
											enabled: setting4aColumn.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting4aImg()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting4aImg()}
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting1Button
								title: qsTr("Notes in different octaves in the same measure")
							}
							StyledFrame {
								visible: setting1Button.isExpanded
								
								ColumnLayout {
									id: setting1Column
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting1Acc.checked
									
									DynamicImage {id: setting1Image}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting1Acc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting1Img()}
											onActivated: {updatesetting1Img()}
										}
										MU.CheckBox {
											id: setting13Box
											enabled: setting1Column.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting1Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting1Img()}
										}
										DurationModeItem {
											id: setting1Duration
											enabled: setting1Column.accOn
											onClicked: updatesetting1Img()
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting4bButton
								title: qsTr("Notes in different octaves in the next measure")
							}
							StyledFrame {
								visible: setting4bButton.isExpanded
								
								ColumnLayout {
									id: setting4bColumn
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting4bAcc.checked
									
									DynamicImage {id: setting4bImage}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting4bAcc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting4bImg()}
											onActivated: {updatesetting4bImg()}
										}
										MU.CheckBox {
											id: setting4b3Box
											enabled: setting4bColumn.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting4bImg()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting4bImg()}
										}
									}
								}
							}
						}
					}
				}
				MU.SeparatorLine {width: mainWindow.width}
				ColumnLayout {
					spacing: regSpace
					Layout.margins: regSpace
					
					MenuButton {
						id: differentStaffButton
						title: qsTr("Notes in different staves of the same instrument")
					}
					ColumnLayout {
						spacing: maxSpace
						Layout.leftMargin: regSpace
						visible: differentStaffButton.isExpanded
						
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting2Button
								title: qsTr("Notes in the same octave in the same measure")
							}
							StyledFrame {
								visible: setting2Button.isExpanded
								
								ColumnLayout {
									id: setting2Column
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting2Acc.checked
									
									DynamicImage {id: setting2Image}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting2Acc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting2Img()}
											onActivated: {updatesetting2Img()}
										}
										MU.CheckBox {
											id: setting23Box
											enabled: setting2Column.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting2Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting2Img()}
										}
										DurationModeItem {
											id: setting2Duration
											enabled: setting2Column.accOn
											onClicked: updatesetting2Img()
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting5aButton
								title: qsTr("Notes in the same octave in the next measure")
							}
							StyledFrame {
								visible: setting5aButton.isExpanded
								
								ColumnLayout {
									id: setting5aColumn
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting5aAcc.checked
									
									DynamicImage {id: setting5aImage}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting5aAcc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting5aImg()}
											onActivated: {updatesetting5aImg()}
										}
										MU.CheckBox {
											id: setting5a3Box
											enabled: setting5aColumn.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting5aImg()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting5aImg()}
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting3Button
								title: qsTr("Notes in different octaves in the same measure")
							}
							StyledFrame {
								visible: setting3Button.isExpanded
								
								ColumnLayout {
									id: setting3Column
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting3Acc.checked
									
									DynamicImage {id: setting3Image}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting3Acc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting3Img()}
											onActivated: {updatesetting3Img()}
										}
										MU.CheckBox {
											id: setting33Box
											enabled: setting3Column.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting3Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting3Img()}
										}
										DurationModeItem {
											id: setting3Duration
											enabled: setting3Column.accOn
											onClicked: updatesetting3Img()
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting5bButton
								title: qsTr("Notes in different octaves in the next measure")
							}
							StyledFrame {
								visible: setting5bButton.isExpanded
								
								ColumnLayout {
									id: setting5bColumn
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting5bAcc.checked
									
									DynamicImage {id: setting5bImage}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting5bAcc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting5bImg()}
											onActivated: {updatesetting5bImg()}
										}
										MU.CheckBox {
											id: setting5b3Box
											enabled: setting5bColumn.accOn
											text: qsTr("Add cautionary if note with accidental is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting5bImg()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting5bImg()}
										}
									}
								}
							}
						}
					}
				}
				MU.SeparatorLine {width: mainWindow.width}
				ColumnLayout {
					spacing: regSpace
					Layout.margins: regSpace
					
					MenuButton {
						id: keySigButton
						title: qsTr("Notes after key signature changes")
					}
					ColumnLayout {
						spacing: maxSpace
						Layout.leftMargin: regSpace
						visible: keySigButton.isExpanded
						
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting7Button
								title: qsTr("Notes after measure key signature changes")
							}
							StyledFrame {
								visible: setting7Button.isExpanded
								
								ColumnLayout {
									id: setting7Column
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting7Acc.checked
									
									DynamicImage {id: setting7Image}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting7Acc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting7Img()}
											onActivated: {updatesetting7Img()}
										}
										MU.CheckBox {
											id: setting74Box
											enabled: setting7Column.accOn
											text: qsTr("Add cautionary if note before key change is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting7Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting7Img()}
										}
										MU.CheckBox {
											id: setting73Box
											enabled: setting7Column.accOn
											text: qsTr("Add cautionary accidentals to notes in any octave")
											checked: false
											onClicked: {checked = !checked; updatesetting7Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting7Img()}
										}
										CancelModeItem {
											id: setting7Cancel
											enabled: setting7Column.accOn && setting73Box.checked
											onClicked: updatesetting7Img()
										}
									}
								}
							}
						}
						ColumnLayout {
							spacing: regSpace
							
							MenuButton {
								id: setting8Button
								title: qsTr("Notes after mid-measure key signature changes")
							}
							StyledFrame {
								visible: setting8Button.isExpanded
								
								ColumnLayout {
									id: setting8Column
									anchors.margins: regSpace
									spacing: regSpace
									property bool accOn: setting8Acc.checked
									
									DynamicImage {id: setting8Image}
									
									ColumnLayout {
										spacing: regSpace
										Layout.leftMargin: regSpace
										width: parent.width - Layout.leftMargin
										
										AddAccItem {
											id: setting8Acc
											Layout.rightMargin: regSpace
											implicitWidth: parent.width - Layout.rightMargin
											onClicked: {updatesetting8Img()}
											onActivated: {updatesetting8Img()}
										}
										MU.CheckBox {
											id: setting84Box
											enabled: setting8Column.accOn
											text: qsTr("Add cautionary if note before key change is a grace note")
											checked: false
											onClicked: {checked = !checked; updatesetting8Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting8Img()}
										}
										MU.CheckBox {
											id: setting83Box
											enabled: setting8Column.accOn
											text: qsTr("Add cautionary accidentals to notes in any octave")
											checked: false
											onClicked: {checked = !checked; updatesetting8Img()}
											signal setv(bool checked)
											onSetv: function(value) {checked = value; updatesetting8Img()}
										}
										CancelModeItem {
											id: setting8Cancel
											enabled: setting8Column.accOn && setting83Box.checked
											onClicked: updatesetting8Img()
										}
									}
								}
							}
						}
					}
				}
			}
		}
		Rectangle {
			height: maxSpace
			anchors.top: flickable.top
			anchors.left: flickable.left
			anchors.right: flickable.right
			anchors.rightMargin: scrollBar.width
			visible: flickable.isScrollable
			gradient: Gradient {
				GradientStop {position: 0.0; color: ui.theme.backgroundSecondaryColor}
				GradientStop {position: 1.0; color: "transparent"}
			}
		}

		Rectangle {
			height: maxSpace
			anchors.left: flickable.left
			anchors.right: flickable.right
			anchors.rightMargin: scrollBar.width
			anchors.bottom: flickable.bottom
			visible: flickable.isScrollable
			gradient: Gradient {
				GradientStop {position: 0.0; color: "transparent"}
				GradientStop {position: 1.0; color: ui.theme.backgroundSecondaryColor}
			}
		}
		footer: Rectangle {
			color: ui.theme.backgroundPrimaryColor
			height: okButton.height + (2 * regSpace) + 1
			MU.SeparatorLine {
				anchors.top: parent.top
			}
			MU.FlatButton {
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				anchors.margins: regSpace
				text: qsTr("Reset Settings")
				onClicked: {loadSettings(DSettings.read())}
			}
			Row {
				id: okButton
				spacing: regSpace
				anchors.margins: regSpace
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				
				MU.FlatButton {
					text: qsTr("Cancel")
					onClicked: {
						smartQuit()
					}
				}
				MU.FlatButton {
					text: qsTr("OK")
					accentButton: true
					onClicked: {
						options.uSettings = JSON.stringify(writeSettings())
						smartQuit()
					}
				}
			}
		}
		Component.onCompleted: {
			if (JSON.parse(options.uSettings).edited) {
				loadSettings(JSON.parse(options.uSettings))
			} else {
				loadSettings(DSettings.read())
			}
			width = Math.max(width, flickable.contentWidth)
		}
	}
	function loadSettings(settingObj) {
		setting0Box.setv(settingObj.setting0.addNaturals)
		//
		setting1Acc.setv(settingObj.setting1.addAccidentals, settingObj.setting1.bracketType)
		setting13Box.setv(settingObj.setting1.parseGraceNotes)
		setting1Duration.setv(settingObj.setting1.durationMode)
		//
		setting2Acc.setv(settingObj.setting2.addAccidentals, settingObj.setting2.bracketType)
		setting23Box.setv(settingObj.setting2.parseGraceNotes)
		setting2Duration.setv(settingObj.setting2.durationMode)
		//
		setting3Acc.setv(settingObj.setting3.addAccidentals, settingObj.setting3.bracketType)
		setting33Box.setv(settingObj.setting3.parseGraceNotes)
		setting3Duration.setv(settingObj.setting3.durationMode)
		//
		setting4aAcc.setv(settingObj.setting4.a.addAccidentals, settingObj.setting4.a.bracketType)
		setting4a3Box.setv(settingObj.setting4.a.parseGraceNotes)
		//
		setting4bAcc.setv(settingObj.setting4.b.addAccidentals, settingObj.setting4.b.bracketType)
		setting4b3Box.setv(settingObj.setting4.b.parseGraceNotes)
		//
		setting5aAcc.setv(settingObj.setting5.a.addAccidentals, settingObj.setting5.a.bracketType)
		setting5a3Box.setv(settingObj.setting5.a.parseGraceNotes)
		//
		setting5bAcc.setv(settingObj.setting5.b.addAccidentals, settingObj.setting5.b.bracketType)
		setting5b3Box.setv(settingObj.setting5.b.parseGraceNotes)
		//
		setting6aAcc.setv(settingObj.setting6.a.addAccidentals, settingObj.setting6.a.bracketType)
		//
		setting6bAcc.setv(settingObj.setting6.b.addAccidentals, settingObj.setting6.b.bracketType)
		//
		setting7Acc.setv(settingObj.setting7.addAccidentals, settingObj.setting7.bracketType)
		setting73Box.setv(settingObj.setting7.cancelOctaves)
		setting7Cancel.setv(settingObj.setting7.cancelMode ? 1 : 2)
		setting74Box.setv(settingObj.setting7.parseGraceNotes)
		//
		setting8Acc.setv(settingObj.setting8.addAccidentals, settingObj.setting8.bracketType)
		setting83Box.setv(settingObj.setting8.cancelOctaves)
		setting8Cancel.setv(settingObj.setting8.cancelMode ? 1 : 2)
		setting84Box.setv(settingObj.setting8.parseGraceNotes)
		//
		setting9aCancel.setv(settingObj.setting9.a ? 1 : 2)
		//
		setting9bCancel.setv(settingObj.setting9.a ? 1 : 2)
	}
	function writeSettings() {
		var settingObj = {}
		settingObj.edited = true
		settingObj.setting0 = {
			addNaturals: setting0Box.checked
		}
		settingObj.setting1 = {
			addAccidentals: setting1Acc.checked,
			bracketType: setting1Acc.currentValue,
			parseGraceNotes: setting13Box.checked,
			durationMode: setting1Duration.value
		}
		settingObj.setting2 = {
			addAccidentals: setting1Acc.checked,
			bracketType: setting1Acc.currentValue,
			parseGraceNotes: setting13Box.checked,
			durationMode: setting1Duration.value
		}
		settingObj.setting3 = {
			addAccidentals: setting3Acc.checked,
			bracketType: setting3Acc.currentValue,
			parseGraceNotes: setting33Box.checked,
			durationMode: setting3Duration.value
		}
		settingObj.setting4 = {
			a: {
				addAccidentals: setting4aAcc.checked,
				bracketType: setting4aAcc.currentValue,
				parseGraceNotes: setting4a3Box.checked
			},
			b: {
				addAccidentals: setting4bAcc.checked,
				bracketType: setting4bAcc.currentValue,
				parseGraceNotes: setting4b3Box.checked
			}
		}
		settingObj.setting5 = {
			a: {
				addAccidentals: setting5aAcc.checked,
				bracketType: setting5aAcc.currentValue,
				parseGraceNotes: setting5a3Box.checked
			},
			b: {
				addAccidentals: setting5bAcc.checked,
				bracketType: setting5bAcc.currentValue,
				parseGraceNotes: setting5b3Box.checked
			}
		}
		settingObj.setting6 = {
			a: {
				addAccidentals: setting6aAcc.checked,
				bracketType: setting6aAcc.currentValue
			},
			b: {
				addAccidentals: setting6bAcc.checked,
				bracketType: setting6bAcc.currentValue
			}
		}
		settingObj.setting7 = {
			addAccidentals: setting7Acc.checked,
			bracketType: setting7Acc.currentValue,
			cancelOctaves: setting73Box.checked,
			parseGraceNotes: setting74Box.checked,
			cancelMode: setting7Cancel.value == 1
		}
		settingObj.setting8 = {
			addAccidentals: setting8Acc.checked,
			bracketType: setting8Acc.currentValue,
			cancelOctaves: setting83Box.checked,
			parseGraceNotes: setting84Box.checked,
			cancelMode: setting8Cancel.value == 1
		}
		settingObj.setting9 = {
			a: setting9aCancel.value == 1,
			b: setting9bCancel.value == 1
		}
		return settingObj
	}
	function updatesetting0Img() {
		setting0Image.source = "examples/setting0/example-" + setting0Box.checked.toString() + ".svg"
	}
	function updatesetting1Img() {
		var imgsource = "examples/setting1/example-"
		if (setting1Acc.checked) {
			imgsource += setting1Acc.currentValue.toString()
			imgsource += setting1Duration.value.toString()
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting1Image.source = imgsource
	}
	function updatesetting2Img() {
		var imgsource = "examples/setting2/example-"
		if (setting2Acc.checked) {
			imgsource += setting2Acc.currentValue.toString()
			imgsource += setting2Duration.value.toString()
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting2Image.source = imgsource
	}
	function updatesetting3Img() {
		var imgsource = "examples/setting3/example-"
		if (setting3Acc.checked) {
			imgsource += setting3Acc.currentValue.toString()
			imgsource += setting3Duration.value.toString()
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting3Image.source = imgsource
	}
	function updatesetting4aImg() {
		var imgsource = "examples/setting4a/example-"
		if (setting4aAcc.checked) {
			imgsource += setting4a3Box.checked ? "1" : "0"
			imgsource += setting4aAcc.currentValue.toString()
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting4aImage.source = imgsource
	}
	function updatesetting4bImg() {
		var imgsource = "examples/setting4b/example-"
		if (setting4bAcc.checked) {
			imgsource += setting4b3Box.checked ? "1" : "0"
			imgsource += setting4bAcc.currentValue.toString()
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting4bImage.source = imgsource
	}
	function updatesetting5aImg() {
		var imgsource = "examples/setting5a/example-"
		imgsource += setting5aAcc.checked ? (setting5aAcc.currentValue + 2).toString() : "1"
		imgsource += ".svg"
		setting5aImage.source = imgsource
	}
	function updatesetting5bImg() {
		var imgsource = "examples/setting5b/example-"
		imgsource += setting5bAcc.checked ? (setting5bAcc.currentValue + 2).toString() : "1"
		imgsource += ".svg"
		setting5bImage.source = imgsource
	}
	function updatesetting6Img() {
		var imgsource = "examples/setting6/example-"
		imgsource += setting6aAcc.checked ? (setting6aAcc.currentValue + 2).toString() : "1"
		imgsource += ".svg"
		setting6Image.source = imgsource
	}
	function updatesetting7Img() {
		var imgsource = "examples/setting7/example-"
		if (setting7Acc.checked) {
			imgsource += setting74Box.checked ? "1" : "0"
			imgsource += setting7Acc.currentValue.toString()
			imgsource += setting73Box.checked ? setting7Cancel.value.toString() : "0"
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting7Image.source = imgsource
	}
	function updatesetting8Img() {
		var imgsource = "examples/setting8/example-"
		if (setting8Acc.checked) {
			imgsource += setting8Acc.currentValue.toString()
			imgsource += setting83Box.checked ? setting8Cancel.value.toString() : "0"
		} else {
			imgsource += "false"
		}
		imgsource += ".svg"
		setting8Image.source = imgsource
	}
	function updatesetting9aImg() {
		setting9aImage.source = "examples/setting9a/example-" + setting9aCancel.value.toString() + ".svg"
	}
	function updatesetting9bImg() {
		setting9bImage.source = "examples/setting9b/example-" + setting9bCancel.value.toString() + ".svg"
	}
	Settings {
		id: options
		category: "Cautionary Accidentals Plugin"
		property var uSettings: '{
			"version": "4.0-beta",
			"edited": false
		}'
		//Qt.labs.settings doesn't like working with object types
	}
	function smartQuit() {
		mainWindow.close()
		if (mscoreMajorVersion < 4) {Qt.quit()}
		else {quit()}
	}//smartQuit
}
