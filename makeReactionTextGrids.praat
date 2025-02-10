# makeReactionTextGrids.praat. Praat script to make TextGrids from the
# times of listeners' reactions to audio samples and their comments.
# See separate documentation file.

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
form: "Make TextGrid from reaction data..."
	sentence: "Column_containing_times", "_time"
	sentence: "Column_containing_user_IDs", "_uid"
	sentence: "Column_containing_comments", "_comment"
endform

time_col$ = column_containing_times$
uid_col$ = column_containing_user_IDs$
comm_col$ = column_containing_comments$

sound = selected ("Sound")
table = selected ("Table")

name$ = selected$ ("Sound")

selectObject: table

# make a copy of the table
# copyTable = Copy: "copyTable"
# sort the table by user ID
# Sort rows: { uid_col$ }
# set all the duplicated user IDs to zero; slow but seems to do the job
# rows = Get number of rows
# for r from 1 to rows-1
#	val = Get value: r, uid_col$
#	checkRow = r+1
#	repeat
#		checkVal = Get value: checkRow, uid_col$
#		if checkVal = val
#			Set numeric value: checkRow, uid_col$, 0
#		endif
#		checkRow = checkRow + 1
#	until checkRow > rows
# endfor
# create a table containing only uniq user IDs (those greater than 0)
# uniqTable = Extract rows where column (number): "_uid", "greater than", 0

# get the user IDs as a vector
uids# = Get all numbers in column: uid_col$

# sort the vector
uids# = sort# (uids#)

# get the items from the sorted vector into an array
for v to size (uids#)
	array[v] = uids#[v]
endfor

# make any duplicates undefined 
for x from 2 to size (uids#)
	if uids#[x] = uids#[x-1]
		array[x] = undefined
	endif
endfor

# count the number of times there are non-undefined dimensions
hits = 0
for y to size (uids#)
	if array[y] <> undefined
		hits = hits + 1
		newArray[hits] = array[y]
	endif
endfor

# prepare the vector to store the unique numbers by creating the relevant number of zeros
uids# = zero# (hits)

# populate the new vector with the unique numbers
for h to hits
	uids# [h] = newArray [h]
endfor

# extract the rows relating to each user ID into a new table and make a new TextGrid
for i from 1 to size (uids#)
	uid$ = string$ (uids# [i])
	selectObject: table
	uidTable = Extract rows where column (number): uid_col$, "equal to", uids# [i]
	selectObject: sound
	uidTG = To TextGrid: uid$, uid$
	Rename: uid$

	selectObject: uidTable
	commRows = Get number of rows

	# add points for each click
	for c to commRows

		# get information about the datapoint
		uid = Get value: c, uid_col$
		comment$ = Get value: c, comm_col$
		time = Get value: c, time_col$

		# set time to 0 if there is no time given, to preserve click and the comment (if present)
		if time = undefined
			time = 0
		endif
	
		# add the datapoint to the TextGrid
		selectObject: uidTG
		Insert point: 1, time, comment$
		selectObject: uidTable

	endfor

	selectObject: uidTable
	Remove

endfor

# select all the new TextGrids
selectObject: "TextGrid " + string$ (uids# [1])
for i from 2 to size (uids#)
	plusObject: "TextGrid " + string$ (uids# [i])
endfor

# get details of the selected TextGrids into a vector
uidTGs# = selected# ()

# merge the TextGrids
merged = Merge
Rename: name$

# use the vector to reselect the new TextGrids and remove them
selectObject: uidTGs# [1]
for s from 2 to size (uidTGs#)
	plusObject: uidTGs# [s]
endfor
Remove

# give the new TextGrid the same name as the original Sound
selectObject: merged
Rename: name$