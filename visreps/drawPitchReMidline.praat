# a script to drawing pitch in semitones relative to a midline 
# (e.g. median, mean, mode or some other measure)

# Copyright (C) 2024 Gareth Walker.

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

form: "Draw relative to midline value"
  	real: "left_Time_range_(s)", "0"
  	real: "right_Time_range_(s)", "0 (=all)"
	positive: "midline_(Hz)", "150"
	real: "baseline_(ST)", "-3"
	real: "topline_(ST)", "8"
	real: "mark_in_lower_section_(ST)", "0 (=no mark)" 
	real: "mark_in_upper_section_(ST)", "0 (=no mark)"
	#real: "marks_bottom_every_(s)", "0.2"
	sentence: "y_axis_label", "Pitch re. mode (ST)"
endform

if left_Time_range = 0
	start = Get start time
	left_Time_range = start  
endif
if right_Time_range = 0
	end = Get end time
	right_Time_range = end
endif

pitch = selected ("Pitch")

#copy = Copy: "copy"
#Formula: "hertzToSemitones(self)-hertzToSemitones(midline)"

Speckle: 0, 0, baseline, topline, "no"
Draw inner box
Text left: "yes", y_axis_label$
Text bottom: "yes", "Time (s)"

frames = Get number of frames

for i from 1 to frames
	time = Get time from frame number: i
	if time > left_Time_range and time < right_Time_range
	    value = Get value in frame: i, "Hertz"
		if value <> undefined
			valueST = hertzToSemitones(midline)-hertzToSemitones(value)
			if valueST > baseline and valueST < topline
				Paint circle (mm): "black", time, valueST, 1.0
			endif
		endif
	endif
endfor

####### GARNISH

One mark bottom: 'left_Time_range:3', "yes", "yes", "no", ""
One mark bottom: 'right_Time_range:3', "yes", "yes", "no", ""

One mark left: 0, "no", "yes", "no", "0"
One mark left: baseline, "yes", "yes", "no", ""
One mark left: topline, "yes", "yes", "no", ""

if mark_in_lower_section <> 0
	One mark left: mark_in_lower_section, "yes", "yes", "no", ""
endif

if mark_in_upper_section <> 0
	One mark left: mark_in_upper_section, "yes", "yes", "no", ""
endif

#Remove

selectObject: pitch