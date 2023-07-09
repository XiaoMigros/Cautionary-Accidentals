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

MuseScore {
	version: "4.0-beta"
	menuPath: "Plugins." + qsTr("Accidentals") + "." + qsTr("Remove Cautionary Accidentals")
	description: qsTr("This plugin removes cautionary accidentals from the score")
	requiresScore: true
	
	Component.onCompleted: {
		if (mscoreMajorVersion >= 4) {
			title = qsTr("Remove Cautionary Accidentals")
			categoryCode = "composing-arranging-tools"
			thumbnailName = "assets/logo.png"
		}
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
	onRun: {
		curScore.startCmd()
		if (!curScore.selection.elements.length) {
			console.log("No selection. Applying plugin to all notes...")
			cmd("select-all")
		} else {
			console.log("Applying plugin to selection")
		}
		var notes = []
		for (var i in curScore.selection.elements) {
			if (curScore.selection.elements[i].type == Element.NOTE) {
				destateAccidental(curScore.selection.elements[i])
			}
		}
		curScore.endCmd()
	}
	function destateAccidental(note) {
		if (note.accidental) {
			var oldAccidental = note.accidentalType
			if (note.accidentalType == Accidental.NATURAL_FLAT) {
				oldAccidental = Accidental.FLAT
			}
			if (note.accidentalType == Accidental.NATURAL_SHARP) {
				oldAccidental = Accidental.SHARP
			}
		}
		var oldPitch = note.pitch
		note.accidentalType = Accidental.NONE
		if (note.pitch != oldPitch) {
			note.accidentalType = oldAccidental
			console.log("Keeping existing accidental for note " + tpcToName(note.tpc))
		} else {
			console.log("Removing accidental from note " + tpcToName(note.tpc))
		}
	}
}
