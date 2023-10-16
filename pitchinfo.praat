# pitchinfo.praat This script lets you make a selection on a pitch
# trace and using Praat's functions from Praat's 'Query' menu, outputs
# data (min, max, mean, range, s.d.) on the selection. The script
# should be run from the Pitch editor window.
 
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

writeInfo: ""

# get details of selected objects
objects# = selected# ()

# gets current editor sequential ID i.e. number in Objects list and
# selects correct object
edInfo$ = Editor info
edID$ = extractWord$ (edInfo$, "Editor name: ")

# gets start and end of selection
start = Get start of selection
end = Get end of selection

# leaves the editor and prints the info
endeditor
select 'edID$' 

appendInfoLine: "Pitch info for selection:"
appendInfoLine: "-------------------------"
min = Get minimum: 'start', 'end', "Hertz", "None"
appendInfoLine: "min (Hz) =", tab$, 'min:2'
max = Get maximum: 'start', 'end', "Hertz", "None"
appendInfoLine: "max (Hz) =", tab$, 'max:2'
median = Get quantile: 'start', 'end', 0.5, "Hertz"
appendInfoLine: "median (Hz) =", tab$, 'median:2'
mean = Get mean: 'start', 'end', "Hertz"
appendInfoLine: "mean (Hz) =", tab$, 'mean:2'
range$ = Calculator: "12*log2('max'/'min')"
range = number(range$)
appendInfoLine: "range (ST) =", tab$, 'range:2'
sd = Get standard deviation: 'start', 'end', "Hertz"
appendInfoLine: "st.dev. (Hz) =", tab$, 'sd:2'  

# restore selection
selectObject (objects#)
