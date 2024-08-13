# pitchDistribution.praat. Praat script to draw a histogram of pitch
# values from a selected Pitch object.

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

form: "Select your options"
	real: "Bin_size_(Hz)", "1"
	boolean: "Draw", "on"
	boolean: "Erase_all", "off"
	real: "x_min_(Hz)", "0 (= all)"
	real: "x_max_(Hz)", "0 (= all)"
	real: "y_min_(n)", "0 (= all)"
	real: "y_max_(n)", "0 (= all)"
	real: "mark_bottom_every_(Hz)", "50 (= 0 for no interim marks)"
	real: "mark_left_every_(n)", "10 (= 0 for no interim marks)"
	sentence: "Colour_({r,g,b})", "{0.5,0.5,0.5}"
	sentence: "text_left", "%%n%"
	sentence: "text_bottom", "Pitch (Hz)"
	boolean: "Garnish", "on"
	boolean: "Name_at_top", "off"
	boolean: "Mark_median", "off"
	boolean: "Mark_5th_and_95th_percentile", "off"
endform

##### PITCH CALCULATIONS

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

# get maximum and minimum
p_min = Get minimum: 0, 0, "Hertz", "none"
p_max = Get maximum: 0, 0, "Hertz", "none"
p_median = Get quantile: 0, 0, 0.5, "Hertz"
p_5 = Get quantile: 0, 0, 0.05, "Hertz"
p_10 = Get quantile: 0, 0, 0.95, "Hertz"

# round the floor and ceiling down and up to whole numbers which are integer multiples
# of the bin size
p_min_round = bin_size*(floor(p_min/bin_size))
p_max_round = bin_size*(ceiling(p_max/bin_size))

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

##### DRAWING

if draw = 1

	if erase_all = 1
		Erase all
	endif

	selectObject: table
	# get minimum and maximum counts
	min_n = Get minimum: "n"
	max_n = Get maximum: "n"
	
	if x_min = 0 
		x_min = p_min_round
	endif
	if x_max = 0 
		x_max = p_max_round
	endif
	
	if y_min = 0 
		y_min = min_n
	endif
	if y_max = 0 
		y_max = max_n
	endif
	
	Axes: x_min, x_max, y_min, y_max
	
	rows = Get number of rows
	
	for r to rows
		bin_bottom = Get value: r, "pitch"
		n = Get value: r, "n"
		# prevent the bar being drawn off the top of the graph
		if n > y_max
			n = y_max
		endif
		# draw the rectangle if it is between the minimum and maximum on the x axis, 
		# and above the minimum on the y axis
		if bin_bottom > x_min and bin_bottom < x_max+bin_size and n > y_min
			Paint rectangle: colour$, bin_bottom, bin_bottom+bin_size, y_min, n
		endif
	endfor
	
	if garnish = 1
		if mark_bottom_every <> 0
			Marks bottom every: 1, mark_bottom_every, "yes", "yes", "no"
		else
			p_min_round$ = string$ (p_min_round)
			p_max_round$ = string$ (p_max_round)
			One mark bottom: p_min_round, "yes", "yes", "no", p_min_round$
			One mark bottom: p_max_round, "yes", "yes", "no", p_max_round$
		endif
		if mark_left_every <> 0
			Marks left every: 1, mark_left_every, "yes", "yes", "no"
		else
			y_min$ = string$ (y_min)
			y_max$ = string$ (y_max)
			One mark left: y_min, "yes", "yes", "no", y_min$
			One mark left: y_max, "yes", "yes", "no", y_max$
		endif
		Text bottom: "yes", text_bottom$
		Text left: "yes", text_left$
		Draw inner box
		if name_at_top = 1
			new_pitch$ = replace$ (pitch$, "_", "\_ ", 0)
			Text top: "yes", new_pitch$
		endif
	endif
	selectObject: pitch

	# to mark the median
	if mark_median = 1
		One mark top: p_median, "no", "yes", "yes", ""
	endif

	# to mark the 5th and 95th percentiles
	if mark_5th_and_95th_percentile = 1
		One mark top: p_5, "no", "yes", "yes", ""
		One mark top: p_10, "no", "yes", "yes", ""
	endif

endif