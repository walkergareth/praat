# drawLabelsAbove.praat. Praat script to allow the drawing of labels
# from a tier in a TextGrid at the top of the current selection in the
# Picture window.

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

form: "Draw labels above..." 
  real: "Tier", "1"
  real: "Font_size", "0 (= current)"
  boolean: "Draw_tics", "on"
  boolean: "Show_boundaries", "off"
endform

# get Picture information
picInfo$ = Picture info
axisLeft = extractNumber(picInfo$, "Axis left:")
axisRight = extractNumber(picInfo$, "Axis right:")
axisTop = extractNumber(picInfo$, "Axis top:")
axisBottom = extractNumber(picInfo$, "Axis bottom:")
ivpTop = extractNumber(picInfo$, "Inner viewport top:")
ivpBottom = extractNumber(picInfo$, "Inner viewport bottom:")
ovpTop = extractNumber(picInfo$, "Outer viewport top:")
ovpBottom = extractNumber(picInfo$, "Outer viewport bottom:")
font$ = extractWord$(picInfo$, "Font:")
if font_size = 0 
  font_size = extractNumber(picInfo$, "Font size:") 
endif

# temporarily adjust y-axis
Axes: axisLeft, axisRight, 0, 1

# calculations
xAxis = axisTop-axisBottom
ivpXAxis = ivpBottom-ivpTop
ovpXAxis = ovpBottom-ovpTop
# vertical position of labels
place = ((xAxis/ivpXAxis)*((ivpTop-ovpTop)/10))+axisTop

# extract portion of TextGrid corresponding to axis
textGrid = selected ("TextGrid")
newTextGrid = Extract part: axisLeft, axisRight, "yes"

# write out labels
intTier = Is interval tier: tier
if intTier = 1
  # labels from interval tiers
  startInt = Get interval at time: tier, axisLeft
  endInt = Get interval at time: tier, axisRight
  for i from startInt to endInt
    text$ = Get label of interval: tier, i
    begin = Get start time of interval: tier, i
    end = Get end time of interval: tier, i
    Text special: begin+((end-begin)/2), "Centre", place, "Bottom", font$, font_size, "0", text$
    if begin > axisLeft 
      One mark top: begin, 0, draw_tics, show_boundaries, ""
    endif
  endfor
elsif intTier = 0
  points = Get number of points: tier
  for i to points
    text$ = Get label of point: tier, i
    pointTime = Get time of point: tier, i
    Text special: pointTime, "Centre", place, "Bottom", font$, font_size, "0", text$
    if pointTime > axisLeft 
      One mark top: pointTime, 0, draw_tics, show_boundaries, ""
    endif
  endfor
endif

Remove
selectObject: textGrid

# restore y-axis
Axes: axisLeft, axisRight, axisBottom, axisTop