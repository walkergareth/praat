# markRecord.praat.  Praat script for to allow you to draw evenly
# spaced marks over a specified portion of a spectrogram, waveform, or
# other acoustic record which shows time on the x-axis.

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

form: "Add marks on record..."
	real: "start_(s)", "0"
	real: "end_(s)", "1"
	real: "number_of_divisions", "10"
	real: "decimal_places_(for_labels)", "0"
endform

dur = end - start
marks_every = dur / number_of_divisions

for i from 0 to number_of_divisions
	markAt = start + (marks_every * i)
	perc = (100 / number_of_divisions) * i
	# figure out strings for labels depending on whether the division is
	# at a whole number interval
	if perc = round (perc)
		perc$ = string$ (perc)
	else
		perc$ = fixed$ (perc, 'decimal_places')
	endif
	One mark top: 'markAt', "no", "yes", "yes", "'perc$'\% "
endfor