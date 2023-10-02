# measureFormantsAtIntervals.praat. A Praat script to look at a
# Formant object and return values for F1 to F5 at equal intervals
# between the first frame and the last.

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

form: "Measure formants at equal intervals..."
	real: "number_of_divisions", "10"
	real: "time_dp", "4"
	real: "formant_dp", "0"
endform

# writes header
writeInfo: "perc", ",", "time"
for x from 1 to 5
	f$ [x] = "F'x'"
	appendInfo:  ",", f$ [x]
endfor
appendInfoLine: ""
# get the first and last frames
fNum = Get number of frames
fStart = Get time from frame number: 1
fEnd = Get time from frame number: fNum
# get the duration
dur = fEnd - fStart
# get the steps between the divisions
measure_every = dur / number_of_divisions
# loop through the divisions
for i from 0 to number_of_divisions
	perc = (100 / number_of_divisions) * i
	time = fStart + (measure_every * i)
	time$ = fixed$ (time, time_dp)
	# loop through the formants
	for x from 1 to 5
		f [x] = Get value at time: x, time, "hertz", "Linear"
		f$ [x] = fixed$ (f [x], formant_dp)
	endfor
	# write out the values
	appendInfo: perc, ",", time$
	for x from 1 to 5
		appendInfo: ",", f$ [x]
	endfor
	appendInfoLine: ""
endfor
