# makeReactionRealTiers.praat. Praat script to make RealTiers from the
# times of listeners' reactions to audio samples. See separate documentation
# file.

# Copyright (C) 2025 Gareth Walker.

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

# sets some options
form: "Make RealTier from reaction data..."
	sentence: "Column_containing_times", "_time"
	positive: "Bin_width_(s)", "0.5"
	positive: "Jump_size_(s)", "0.1"
	sentence: "Name_of_new_objects", "untitled"
endform

time_col$ = column_containing_times$
new_name$ = name_of_new_objects$

# get number of each type of selected object
selTable = numberOfSelected ("Table")
selSound = numberOfSelected ("Sound")

# check the selection is appropriate
if (selTable <> 1 or selSound <> 1)
	exitScript: "You need to select one Sound and one Table. 
		... Check your selection and try again."
endif

# get names
table = selected ("Table")
sound = selected ("Sound")

# get duration of the Sound
selectObject: sound
start = Get start time
end = Get end time

bin_start = start - (bin_width) ; where bins start
bin_end = bin_start + bin_width ; where first bin ends

# select the table containing the times of the reactions
selectObject: table
rows = Get number of rows
name$ = selected$ ("Table")

# create a new RealTier object to contain the reactions.
rt = Create RealTier: new_name$, start, end

###### Create data table

new_Table = Create Table with column names: new_name$, 0, {"bin_start","bin_end","count"}

repeat
  selectObject: table

  # does some rounding (to 4 d.p.)
  bin_start = (round((bin_start*1000)))/1000
  bin_end = (round((bin_end*1000)))/1000

  # a vector containing all the row numbers where the criteria are satisfied
  clicks# = List row numbers where: "self [row,time_col$] >= bin_start and self [row,time_col$] <= bin_end"

  # size of vector (number of rows)
  clicks = size (clicks#)

  # modify new_Table
  selectObject: new_Table
  Append row
  rows = Get number of rows
  Set numeric value: rows, "bin_start", bin_start
  Set numeric value: rows, "bin_end", bin_end
  Set numeric value: rows, "count", clicks

  bin_start = bin_start + jump_size
  bin_end = bin_start + bin_width
# stops when the bin starts after the end of the specified range
until bin_start + (0.5*(bin_end - bin_start)) > end

##### Add the reactions to the RealTier

for r to rows
	selectObject: new_Table
	bin_start = Get value: r, "bin_start"
	bin_end = Get value: r, "bin_end"
	bin_mid = ((bin_end - bin_start)/2) + bin_start
	count = Get value: r, "count"
	selectObject: rt
	Add point: bin_mid, count
	selectObject: new_Table 
endfor

selectObject: sound
plusObject: table