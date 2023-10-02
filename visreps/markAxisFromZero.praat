# markAxisFromZero.praat Praat script to put minor and major tic marks
# on an existing plot in the Picture window.  Labels will always start
# from 0.

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

# form for options
form: "Mark options..."
  real: "Major_mark_x_axis_every_(s)", "1"
  real: "Minor_mark_x_axis_every_(s)", "0 (= none)"
  boolean: "Add_axis_label", "off"
endform

# gets existing picture info
picInfo$ = Picture info
axisLeft = extractNumber(picInfo$, "Axis left:")
axisRight = extractNumber(picInfo$, "Axis right:")
axisTop = extractNumber(picInfo$, "Axis top:")
axisBottom = extractNumber(picInfo$, "Axis bottom:")
axisX = axisRight - axisLeft

# changes x axis to run from 0
Axes: 0, axisX, axisBottom, axisTop

# checks the major and minor axis tics
if minor_mark_x_axis_every > 0
  if major_mark_x_axis_every/minor_mark_x_axis_every <> round(major_mark_x_axis_every/minor_mark_x_axis_every)
    beginPause: "Warning!"
      comment: "Major marks on the x axis are not multiples of the minor marks."
      comment: "X axis labels will look strange."
      clicked = endPause: "Cancel", "Continue", 2, 1
      if clicked = 1
        exitScript ()
      endif
  endif
endif

# does minor marks
if minor_mark_x_axis_every > 0
  minorMarkBottom = (round(0/minor_mark_x_axis_every))*minor_mark_x_axis_every
  repeat
    if minorMarkBottom >= 0
      One mark bottom: minorMarkBottom, "no", "yes", "no", ""
    endif
    minorMarkBottom = minorMarkBottom + minor_mark_x_axis_every
  until 'minorMarkBottom:14' > axisX
endif
# does major marks
if major_mark_x_axis_every > 0 
  majorMarkBottom = (round(0/major_mark_x_axis_every))*major_mark_x_axis_every
  repeat
    if majorMarkBottom >= 0
      if minor_mark_x_axis_every > 0
        One mark bottom: majorMarkBottom, "yes", "no", "no", ""
      elsif minor_mark_x_axis_every = 0
        One mark bottom: majorMarkBottom, "yes", "yes", "no", ""
      endif
    endif
    majorMarkBottom = majorMarkBottom + major_mark_x_axis_every
  until 'majorMarkBottom:14' > axisX
endif

# adds axis label if selected
if add_axis_label = 1
  Text bottom: "yes", "Time (s)"
endif

# resets axis
Axes: axisLeft, axisRight, axisBottom, axisTop