# zeroCrossingSecondChannel.praat This script moves the cursor to the
# nearest zero crossing on the second channel of a stereo file. The
# script should be run from the Sound editor window.
 
# Copyright (C) 2023 Gareth Walker.

# g.walker@sheffield.ac.uk
# School of English
# University of Sheffield
# Jessop West
# 1 Upper Hanover Street
# Sheffield
# S3 7RA

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

# get time of cursor
curs = Get cursor

# gets current editor sequential ID
edInfo$ = Editor info
edID$ = extractWord$ (edInfo$, "Editor name: ")
edNumber$ = replace$(edID$, ".", "", 1)
edNumber = number (edNumber$)

# leaves the editor
endeditor

# get details of selected objects
objects# = selected# ()

# selects the object to match the editor
selectObject: edNumber

# gets the nearest zero crossing on channel 2
nearestZero = Get nearest zero crossing: 2, curs

# go back to the editor and move the cursor
editor: edNumber
Move cursor to: nearestZero

# restore selected objects
selectObject (objects#)