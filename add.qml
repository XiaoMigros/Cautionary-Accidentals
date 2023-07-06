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

import QtQuick 2.0
import MuseScore 3.0
import Qt.labs.settings 1.0
import "assets/defaultsettings.js" as DSettings

MuseScore {
	version: "4.0-beta"
	menuPath: "Accidentals.Add Cautionary Accidentals"
	description: "This plugin adds cautionary accidentals to the score"
	requiresScore: true
	
	Component.onCompleted: {
		if (mscoreMajorVersion >= 4) {
			title = "Add Cautionary Accidentals"
			categoryCode = "composing-arranging-tools"
			thumbnailName = "assets/logo.png"
		}
	}
	
	//todo:
	//add option to restate accidentals coming from chromatic runs
	//fix keysig bug
	
	//Settings vars:
	
	//cancel single accidentals when preceded by double
	property var setting0: true
	
	//notes in same measure at different octave
	property var setting1: [true, 0, true, 0]
	//if to run, bracket type, if to allow grace notes, how to parse durations (0: not before, 1: instantaneous, 2: during)
	
	//notes in same measure in different staves (of same instrument)
	property var setting2: [true, 1, true, 0]
	
	//notes in same measure, different octave, different staves
	property var setting3: [true, 2, true, 2]
	
	//notes in different measure, same & different octave
	property var setting4: [true, 1, true, true, 2, false]
	
	//notes in different measure, same & different octave, different staff
	property var setting5: [true, 1, true, true, 2, false]
	
	//(same) notes after grace notes that add accidental, option apply across staves
	property var setting6: [true, 1, true, 2]
	
	//notes over a key change (new bar)
	property var setting7: [true, 0, true, true, true] //add over staff??
	//if to run, bracket type, if to cancel different octaves, if to allow grace notes, excessive cancelling
	
	//notes over a key change (mid bar)
	property var setting8: [true, 0, true, true, true]
	
	//how to handle excessive cancelling
	property var setting9: [true, true]
	//in same measure, in different measure
	//option true: add accidentals as needed until cancelled in original octave //stop after cancelled in original octave
	//   notes of same tick get cancelled
	//   cancelling has to happen in original staff
	//option false: continue to add accidentals as needed if not previously cancelled in same octave //cancel in all octaves
	
	function loadSettings(settingObj) {
		setting0 = settingObj.setting0.addNaturals
		setting1 = [
			settingObj.setting1.addAccidentals,
			settingObj.setting1.bracketType,
			settingObj.setting1.parseGraceNotes,
			settingObj.setting1.durationMode
		]
		setting2 = [
			settingObj.setting2.addAccidentals,
			settingObj.setting2.bracketType,
			settingObj.setting2.parseGraceNotes,
			settingObj.setting2.durationMode
		]
		setting3 = [
			settingObj.setting3.addAccidentals,
			settingObj.setting3.bracketType,
			settingObj.setting3.parseGraceNotes,
			settingObj.setting3.durationMode
		]
		setting4 = [
			settingObj.setting4.a.addAccidentals,
			settingObj.setting4.a.bracketType,
			settingObj.setting4.a.parseGraceNotes,
			settingObj.setting4.b.addAccidentals,
			settingObj.setting4.b.bracketType,
			settingObj.setting4.b.parseGraceNotes
		]
		setting5 = [
			settingObj.setting4.a.addAccidentals,
			settingObj.setting4.a.bracketType,
			settingObj.setting4.a.parseGraceNotes,
			settingObj.setting4.b.addAccidentals,
			settingObj.setting4.b.bracketType,
			settingObj.setting4.b.parseGraceNotes
		]
		setting6 = [
			settingObj.setting6.a.addAccidentals,
			settingObj.setting6.a.bracketType,
			settingObj.setting6.b.addAccidentals,
			settingObj.setting6.b.bracketType
		]
		setting7 = [
			settingObj.setting7.addAccidentals,
			settingObj.setting7.bracketType,
			settingObj.setting7.cancelOctaves,
			settingObj.setting7.parseGraceNotes,
			settingObj.setting7.cancelMode
		]
		setting8 = [
			settingObj.setting8.addAccidentals,
			settingObj.setting8.bracketType,
			settingObj.setting8.cancelOctaves,
			settingObj.setting8.parseGraceNotes,
			settingObj.setting8.cancelMode
		]
		setting9 = [
			settingObj.setting9.a,
			settingObj.setting9.b
		]
	}
	
	function tpcToName(tpc) {
		var tpcNames = [ //-1 thru 33
			"Fbb", "Cbb", "Gbb", "Dbb", "Abb", "Ebb", "Bbb",
			"Fb",  "Cb",  "Gb",  "Db",  "Ab",  "Eb",  "Bb",
			"F",   "C",   "G",   "D",   "A",   "E",   "B",
			"F#",  "C#",  "G#",  "D#",  "A#",  "E#",  "B#",
			"F##", "C##", "G##", "D##", "A##", "E##", "B##"
		]
		return tpcNames[tpc+1]
	}
	function tpcToNote(tpc) {
		var noteNames = ["C", "G", "D", "A", "E", "B", "F"]
		return noteNames[(tpc+7) % 7]
	}
	
	onRun: {
		if (options.uSettings && JSON.parse(options.uSettings).edited) {
			loadSettings(JSON.parse(options.uSettings))
		} else {
			loadSettings(DSettings.read())
		}
		
		curScore.startCmd()
		if (!curScore.selection.elements.length) {
			console.log("No selection. Applying plugin to all notes...")
			cmd("select-all")
		} else {
			console.log("Applying plugin to selection...")
		}
		var notes = []
		for (var i in curScore.selection.elements) {
			if (curScore.selection.elements[i].type == Element.NOTE && ! curScore.selection.elements[i].staff.part.hasDrumStaff) {
				notes.push(curScore.selection.elements[i])
			}
		}
		notes.sort(function (a,b) {
			//sort notes by tick, prioritise notes with accidentals, prioritise non-doubles to avoid excessive brackets
			if (isSameTick(a,b)) {
				var testCount = 0
				if (a.accidental) {
					testCount--
				}
				if (b.accidental) {
					testCount++
				}
				if (testCount == 0) {
					if (a.accidentalType == Accidental.SHARP2 || a.accidentalType == Accidental.FLAT2) {
						testCount++
					}
					if (b.accidentalType == Accidental.SHARP2 || b.accidentalType == Accidental.FLAT2) {
						testCount++//-- ??
					}
				}
				return testCount
			} else {
				return (tickOfNote(a) - tickOfNote(b))
			}
		})
		for (var i = notes.length-1; i >= 0; i--) {
			if (notes[i].accidental) {
				var notes2 = notes.slice(0)
				addAccidentals(notes2.splice(i, notes2.length)) //notes.subarray non-functional
			} else {
				if (setting7[0] || setting8[0]) {
					var notes2 = notes.slice(0)
					keySigTest(notes2.splice(i, notes2.length))
				}
			}
		}
		curScore.endCmd()
		smartQuit()
	}
	function addAccidentals(noteList) {
		var testNote = noteList.shift()
		var testName = tpcToNote(testNote.tpc)
		console.log("Note with accidental found (" + tpcToName(testNote.tpc) + ").\r\n"
			+ "Attempting to add cautionary accidentals to " + noteList.length + " note(s).")
		var cancelledNotes = []
		for (var j in noteList) {
			var note = noteList[j]
			var changeNote = false
			var changeBracket = []
			if (!note.tieBack) {
				if (setting1[0]) {
					if (isSameNoteName(note, testNote) && !isSamePitch(note, testNote) &&
						isSameMeasure(note, testNote) && isSameStaff(note, testNote) && (setting1[2] || !isGraceNote(testNote))) {
						if (setting1[3] == 0 || (setting1[3] == 1 && isSameTick(note, testNote)) || (setting1[3] == 2 && isSameBeat(note, testNote))) {
							var check = true
							for (var k in cancelledNotes) {
								if (isSameNoteName(note, cancelledNotes[k]) && ((setting9[0] && isSamePitch(testNote, cancelledNotes[k])) ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
									isSameStaff(note, cancelledNotes[k]) && isSameMeasure(note, cancelledNotes[k])) {
									console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
									check = false
									break
								}
							}
							if (check) {
								changeNote = true
								changeBracket.push(setting1[1])
								if (isSameNoteName(note, testNote) && isSameStaff(note, testNote)) {
									//isSameStaff might not be needed here
									cancelledNotes.push(note)
								}
							}
						}
					}
				}
				if (setting2[0]) {
					if (isSameNoteName(note, testNote) && !isSamePitch(note, testNote) && isSameOctave(note, testNote) && isSameMeasure(note, testNote) &&
						!isSameStaff(note, testNote) && isSamePart(note, testNote) && (setting2[2] || !isGraceNote(testNote))) {
						if (setting2[3] == 0 || (setting2[3] == 1 && isSameTick(note, testNote)) || (setting2[3] == 2 && isSameBeat(note, testNote))) {
							var check = true
							for (var k in cancelledNotes) {
								if (isSameNoteName(note, cancelledNotes[k]) && ((setting9[0] && isSamePitch(testNote, cancelledNotes[k])) ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
									isSameStaff(note, cancelledNotes[k]) && isSameMeasure(note, cancelledNotes[k])) {
									console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
									check = false
									break
								}
							}
							if (check) {
								changeNote = true
								changeBracket.push(setting2[1])
								if (isSameNoteName(note, testNote) && isSamePart(note, testNote)) {
									//isSamePart might not be needed here
									cancelledNotes.push(note)
								}
							}
						}
					}
				}
				if (setting3[0]) {
					if (isSameNoteName(note, testNote) && !isSamePitch(note, testNote) && !isSameOctave(note, testNote) && isSameMeasure(note, testNote) &&
						!isSameStaff(note, testNote) && isSamePart(note, testNote) && (setting3[2] || !isGraceNote(testNote))) {
						if (setting3[3] == 0 || (setting3[3] == 1 && isSameTick(note, testNote)) || (setting3[3] == 2 && isSameBeat(note, testNote))) {
							var check = true
							for (var k in cancelledNotes) {
								if (isSameNoteName(note, cancelledNotes[k]) && ((setting9[0] && isSamePitch(testNote, cancelledNotes[k])) ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
									isSameStaff(note, cancelledNotes[k]) && isSameMeasure(note, cancelledNotes[k])) {
									console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
									check = false
									break
								}
							}
							if (check) {
								changeNote = true
								changeBracket.push(setting3[1])
								if (isSameNoteName(note, testNote) && isSamePart(note, testNote)) {
									//isSamePart might not be needed here
									cancelledNotes.push(note)
								}
							}
						}
					}
				}
				if (setting4[0]) {
					if (isSameNoteName(note, testNote) && !isSamePitch(note, testNote) &&
						(isNextMeasure(note, testNote) || isNextMeasure(note, testNote.lastTiedNote)) && isSameStaff(note, testNote)) {
						var check = true
						for (var k in cancelledNotes) {
							if (isSameNoteName(note, cancelledNotes[k]) && ((setting9[0] && isSamePitch(testNote, cancelledNotes[k])) ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
								isSameStaff(note, cancelledNotes[k]) && isSameMeasure(note, cancelledNotes[k])) {
								console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
								check = false
								break
							}
						}
						if (check) {
							if (isSameOctave(note, testNote) && (setting4[2] || !isGraceNote(testNote))) {
								changeNote = true
								changeBracket.push(setting4[1])
							} else if (setting4[3] && (setting4[5] || !isGraceNote(testNote))) {
								changeNote = true
								changeBracket.push(setting4[4])
							}
							if (isSameNoteName(note, testNote) && isSameStaff(note, testNote)) {
								//isSameStaff might not be needed here
								cancelledNotes.push(note)
							}
						}
					}
				}
				if (setting5[0]) {
					if (isSameNoteName(note, testNote) && !isSamePitch(note, testNote) &&
						(isNextMeasure(note, testNote) || isNextMeasure(note, testNote.lastTiedNote)) && !isSameStaff(note, testNote) && isSamePart(note, testNote)) {
						var check = true
						for (var k in cancelledNotes) {
							if (isSameNoteName(note, cancelledNotes[k]) && ((setting9[0] && isSamePitch(testNote, cancelledNotes[k])) ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
								isSameStaff(note, cancelledNotes[k]) && isSameMeasure(note, cancelledNotes[k])) {
								console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
								check = false
								break
							}
						}
						if (check) {
							if (isSameOctave(note, testNote) && (setting5[2] || !isGraceNote(testNote))) {
								changeNote = true
								changeBracket.push(setting5[1])
							} else if (setting5[3] && (setting5[5] || !isGraceNote(testNote))) {
								changeNote = true
								changeBracket.push(setting5[4])
							}
							if (isSameNoteName(note, testNote) && isSamePart(note, testNote)) {
								//isSamePart might not be needed here
								cancelledNotes.push(note)
							}
						}
					}
				}
				if (setting6[0]) {
					if (isSameNoteName(note, testNote) && isSamePitch(note, testNote) && isGraceNote(testNote) && !isGraceNote(note) &&
						isSameMeasure(note, testNote) && (setting6[2] ? isSamePart(note, testNote) : isSameStaff(note, testNote))) {
						var check = true
						for (var k in cancelledNotes) {
							if (isSameNoteName(note, cancelledNotes[k]) && isSamePitch(note, cancelledNotes[k]) && isSameStaff(note, cancelledNotes[k])) {
								//optional: change isSameStaff to (setting6[2] ? isSamePart(note, testNote) : isSameStaff(note, testNote))
								console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
								check = false
								break
							}
						}
						if (check) {
							changeNote = true
							cancelledNotes.push(note)
							if (isSameStaff(note, testNote)) {
								changeBracket.push(setting6[1])
							} else {
								changeBracket.push(setting6[3])
							}
						}
					}
				}
				if (changeNote) {
					if (isSameTick(note, testNote) && (testNote.tpc > 26 || testNote.tpc < 6)) {
						changeBracket.push(0) //dont add brackets to reduced accidentals on same beat //TODO: same measure?
					}
					changeBracket.sort()
					restateAccidental(note, (setting0 ? (testNote.tpc > 26 || testNote.tpc < 6) : false), changeBracket[0])
					if (isSameNoteName(note, testNote) && isSameOctave(note, testNote)) {
						cancelledNotes.push(note)
						//only stop adding cautionary accidentals if note is of the same octave
					}
				}
			}
		}
	}
	function keySigTest(noteList) {
		var testNote = noteList.shift()
		var testName = tpcToNote(testNote.tpc)
		console.log("Testing for key signature changes")
		var cancelledNotes = []
		for (var j in noteList) {
			var note = noteList[j]
			var changeNote = false
			var changeBracket = []
			if (!note.tieBack) {
				if (setting7[0]) {
					if (isSameNoteName(note, testNote) && (setting7[2] ? !isOctavedPitch(note, testNote) : (isSameOctave(note, testNote) && !isSamePitch(note, testNote))) &&
						note.accidentalType == Accidental.NONE && isNextMeasure(note, testNote) && isSameStaff(note, testNote) && (setting7[3] || !isGraceNote(testNote))) {
						var check = true
						for (var k in cancelledNotes) {
							if (isSameNoteName(note, cancelledNotes[k]) && (setting7[4] ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
								isSameStaff(note, cancelledNotes[k])) {
								console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
								check = false
								break
							}
						}
						if (check) {
							changeNote = true
							changeBracket.push(setting7[1])
							if (isSameNoteName(note, testNote) && isSameStaff(note, testNote) && (!setting7[4] || isSameOctave(note, testNote))) {
								cancelledNotes.push(note)
							}
						}
					}
				}
				if (setting8[0]) {
					if (isSameNoteName(note, testNote) && (setting8[2] ? !isOctavedPitch(note, testNote) : (isSameOctave(note, testNote) && !isSamePitch(note, testNote))) &&
						note.accidentalType == Accidental.NONE && isSameMeasure(note, testNote) && isSameStaff(note, testNote) && (setting8[3] || !isGraceNote(testNote))) {
						var check = true
						for (var k in cancelledNotes) {
							if (isSameNoteName(note, cancelledNotes[k]) && (setting8[4] ? isOctavedPitch(note, cancelledNotes[k]) : isSamePitch(note, cancelledNotes[k])) &&
								isSameStaff(note, cancelledNotes[k])) {
								console.log("The accidental in question has been cancelled, no need to add further cautionary accidentals")
								check = false
								break
							}
						}
						if (check) {
							changeNote = true
							changeBracket.push(setting8[1])
							if (isSameNoteName(note, testNote) && isSameStaff(note, testNote) && (!setting8[4] || isSameOctave(note, testNote))) {
								cancelledNotes.push(note)
							}
						}
					}
				}
				if (changeNote) {
					if (isSameTick(note, testNote) && (testNote.tpc > 26 || testNote.tpc < 6)) {
						changeBracket.push(0)
					}
					changeBracket.sort()
					restateAccidental(note, (setting0 ? (testNote.tpc > 26 || testNote.tpc < 6) : false), changeBracket[0])
				}
			}
		}
	}
	function tickOfNote(note) {
		return isGraceNote(note) ? note.parent.parent.parent.tick : note.parent.parent.tick
	}
	function isGraceNote(note) {
		return note.noteType != 0
	}
	function isSameNoteName(note1, note2) {
		return tpcToNote(note1.tpc) == tpcToNote(note2.tpc)
	}
	function isSamePitch(note1, note2) {
		return note1.pitch == note2.pitch
	}
	function isSameOctave(note1, note2) {
		//return 12 * Math.round(note1.pitch/12) == 12 * Math.round(note2.pitch/12)
		return Math.abs(note1.pitch - note2.pitch) < 5
		//only to be used in conjunction with isSameNoteName
	}
	function isOctavedPitch(note1, note2) {
		return note1.pitch % 12 == note2.pitch % 12
	}
	function isSameTick(note1, note2) {
		return tickOfNote(note1) == tickOfNote(note2)
	}
	function isSameBeat(note1, note2) {
		return tickOfNote(note1) < (tickOfNote(note2) + durationOfNote(note2))
	}
	function durationOfNote(note) {
		return isGraceNote(note) ? 0 : note.parent.duration.ticks
	}
	function isSameMeasure(note1, note2) {
		return measureOf(note1).is(measureOf(note2))
	}
	function isNextMeasure(note1, note2) {
		return measureOf(note1).is(curScore.firstMeasure) ? false : measureOf(note1).prevMeasure.is(measureOf(note2))
	}
	function measureOf(note) {
		return isGraceNote(note) ? note.parent.parent.parent.parent : note.parent.parent.parent
	}
	function isSameStaff(note1, note2) {
		return note1.staff.is(note2.staff)
	}
	function isSamePart(note1, note2) {
		return note1.staff.part.is(note2.staff.part)
	}
	function restateAccidental(note, cancelDouble, bracketType) {		
		var oldAccidental = note.accidentalType
		var accidental = Accidental.NONE
		switch (true) {
			case (note.tpc > 26): {
				accidental = Accidental.SHARP2
				break
			}
			case (note.tpc > 19): {
				if (cancelDouble) {
					accidental = Accidental.NATURAL_SHARP
				} else {
					accidental = Accidental.SHARP
				}
				break
			}
			case (note.tpc > 12): {
				accidental = Accidental.NATURAL
				break
			}
			case (note.tpc > 5): {
				if (cancelDouble) {
					accidental = Accidental.NATURAL_FLAT
				} else {
					accidental = Accidental.FLAT
				}
				break
			}
			default: {
				accidental = Accidental.FLAT2
			}
		}
		if (accidental != oldAccidental) {
			note.accidentalType = accidental
			note.accidental.visible = note.visible
			note.accidental.accidentalBracket = bracketType
			console.log("Added a cautionary accidental to note " + tpcToName(note.tpc))
			//0 = none, 1 = parentheses, 2 = brackets
		}
	}
	function smartQuit() {
		if (mscoreMajorVersion < 4) {Qt.quit()}
		else {quit()}
	}//smartQuit
	
	Settings {
		id: options
		category: "Cautionary Accidentals Plugin"
		property var uSettings
	}
}
