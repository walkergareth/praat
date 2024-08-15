# pitchObjectInfo.praat. Praat script for getting information about
# a Pitch object

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

writeInfo: ""

# get details of the selected objects
number_of_selected = numberOfSelected ()
fullName$ = selected$ () ; get full name of selected object
type$ = extractWord$ (fullName$, "") ; get type of object

# abort if the selection is anything other than a single pitch object
if type$ <> "Pitch" or number_of_selected <> 1
	exitScript: "Select a single Pitch object."
endif

pitch = selected ("Pitch") ; get ID
pitch$ = selected$ ("Pitch") ; get name

# get some basic information
duration = Get total duration
frames = Get number of frames
vframes = Count voiced frames
vframesProp = vframes/frames
min = Get minimum: 0, 0, "Hertz", "parabolic"
pc5 = Get quantile: 0, 0, 0.05, "Hertz"
pc10 = Get quantile: 0, 0, 0.1, "Hertz"
median = Get quantile: 0, 0, 0.5, "Hertz"
mean = Get mean: 0, 0, "Hertz"
pc90 = Get quantile: 0, 0, 0.9, "Hertz"
pc95 = Get quantile: 0, 0, 0.95, "Hertz"
max = Get maximum: 0, 0, "Hertz", "parabolic"
sd = Get standard deviation: 0, 0, "Hertz"

appendInfoLine: "duration (s): ", 'duration:2'
appendInfoLine: "frames: ", frames
appendInfoLine: "voiced frames: ", vframes
appendInfoLine: "proportion of voiced frames: ", 'vframesProp:2'
appendInfoLine: "minimum (Hz): ", 'min:2'
appendInfoLine: "5th percentile (Hz): ", 'pc5:2'
appendInfoLine: "10th percentile (Hz): ", 'pc10:2'
appendInfoLine: "median (Hz): ", 'median:2'
appendInfoLine: "mean (Hz): ", 'mean:2'
appendInfoLine: "90th percentile (Hz): ", 'pc90:2'
appendInfoLine: "95th percentile (Hz): ", 'pc95:2'
appendInfoLine: "maximum (Hz): ", 'max:2'
appendInfoLine: "s.d. (Hz): ", 'sd:2'

#### CALCULATE THE MODE

bin_size = 1 ; size of bins (Hz)

# round the floor and ceiling down and up to whole numbers which are integer multiples
# of the bin size
p_min_round = bin_size*(floor(min/bin_size))
p_max_round = bin_size*(ceiling(max/bin_size))

table = Create Table with column names: pitch$ + "_pitchdist", 0, { "pitch", "n" }

# create a table to hold the counts
bin_start = p_min_round
repeat
	Append row
	rows = Get number of rows
	Set numeric value: rows, "pitch", bin_start
	Set numeric value: rows, "n", 0
	bin_start = bin_start + bin_size
until bin_start > p_max_round

# work on the pitch trace
selectObject: pitch

# go through all the frames
frames = Get number of frames
for f to frames
	# get the values
	p_val = Get value in frame: f, "Hertz"
	# process if the value is not undefined
	if p_val <> undefined
		selectObject: table

		# get the last row which is smaller than the pitch value
		hits# = List row numbers where: "p_val > self [row, ""pitch""]"
		rowToAddTo = hits# [size (hits#)]
		# add to the value in that row
		prev_val = Get value: rowToAddTo, "n"
		Set numeric value: rowToAddTo, "n", prev_val+1

		selectObject: pitch
	endif
endfor

# get a list of the rows containing the highest number of values (the mode, or modes)
selectObject: table
n_max = Get maximum: "n"
mode_rows# = List row numbers where: "self [row, ""n""] = n_max"

for m from 1 to size (mode_rows#)
	p_mode = Get value: mode_rows# [m], "pitch"

	minReModeST = hertzToSemitones(p_mode)-hertzToSemitones(min)
	pc5ReModeST = hertzToSemitones(p_mode)-hertzToSemitones(pc5)
	pc10ReModeST = hertzToSemitones(p_mode)-hertzToSemitones(pc10)
	medianReModeST = hertzToSemitones(p_mode)-hertzToSemitones(median)
	meanReModeST = hertzToSemitones(p_mode)-hertzToSemitones(mean)
	pc90ReModeST = hertzToSemitones(p_mode)-hertzToSemitones(pc90)
	pc95ReModeST = hertzToSemitones(p_mode)-hertzToSemitones(pc95)
	maxReModeST = hertzToSemitones(p_mode)-hertzToSemitones(max)

	appendInfoLine: "mode " + string$(m) + " (Hz): ", 'p_mode:0'
	appendInfoLine: "min re. mode " + string$(m) + " (ST): ", 'minReModeST:2'
	appendInfoLine: "5th percentile re. mode " + string$(m) + " (ST): ", 'pc5ReModeST:2'
	appendInfoLine: "10th percentile re. mode " + string$(m) + " (ST): ", 'pc10ReModeST:2'
	appendInfoLine: "median re. mode " + string$(m) + " (ST): ", 'medianReModeST:2'
	appendInfoLine: "mean re. mode " + string$(m) + " (ST): ", 'meanReModeST:2'
	appendInfoLine: "90th percentile re. mode " + string$(m) + " (ST): ", 'pc90ReModeST:2'
	appendInfoLine: "95th percentile re. mode " + string$(m) + " (ST): ", 'pc95ReModeST:2'
	appendInfoLine: "maximum re. mode " + string$(m) + " (ST): ", 'maxReModeST:2'
endfor

Remove
selectObject: pitch