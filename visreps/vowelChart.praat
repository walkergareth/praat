# vowelChart.praat. Praat script to draw F1 and F2 vowel charts. 

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

form: "Draw a vowel chart"
   comment: "Set the axes (all values in Hertz):"
     real: "left_F1_axis", "200"
     real: "right_F1_axis", "1000"
     real: "left_F2_axis", "500"
     real: "right_F2_axis", "3000"
     real: "F1_lines_every_(Hz)", "0 (= no lines)"
     real: "F1_labels_every_(Hz)", "200"
     real: "F2_lines_every_(Hz)", "0 (= no lines)"
     real: "F2_labels_every_(Hz)", "500"
     boolean: "Label_lower_limits", "1"
     boolean: "Garnish_(=_draw_the_grid)", "1"
     boolean: "Erase_all_first", "0"
     optionmenu: "Type_of_plot:", "1"
       option: "Linear (Hz)"
       option: "Logarithmic (Hz)"
  comment: "Plot a point (leave F1 and F2 values at 0 to plot nothing):"
     real: "F1_(Hz)", "0"
     real: "F2_(Hz)", "0"
     word symbol i
  comment: "Draw a line (all values in Hz; leave all values at 0 to plot nothing):"
     real: "left_from_(F1,_F2_in_Hz)", "0"
     real: "right_from_(F1,_F2_in_Hz)", "0"
     real: "left_to_(F1,_F2_in_Hz)", "0"
     real: "right_to_(F1,_F2_in_Hz)", "0"
  optionmenu: "Line_style:", "1"
     option: "plain"
     option: "arrowhead"
     option: "double arrowhead"
endform

if erase_all_first = 1
  Erase all
endif

if type_of_plot = 1
  # sets the axes
  lx = left_F2_axis
  rx = right_F2_axis
  ty = left_F1_axis
  by = right_F1_axis
  Axes: -rx, -lx, -by, -ty
  # does the drawing
  if garnish = 1
    # draws the box
    Draw inner box
    # labels the axes
    Text top: "yes", "F2 (kHz)"
    Text right: "yes", "F1 (kHz)"
    # labels F2 axis
    if f2_lines_every <> 0
      for i from 1 to right_F2_axis/f2_lines_every
        lab = i*f2_lines_every/1000
        if i*f2_lines_every > left_F2_axis and i*f2_lines_every < right_F2_axis
          One mark top: -(i*f2_lines_every), "no", "no", "yes", ""
        endif
    endfor
    endif
    for i from 1 to right_F2_axis/f2_labels_every
      lab = i*f2_labels_every/1000 
      if i*f2_labels_every > left_F2_axis and i*f2_labels_every <= right_F2_axis
        One mark top: -(i*f2_labels_every), "no", "yes", "no", "'lab'"
      endif
    endfor
    # labels F1 axis
    if f1_lines_every <> 0
      for i from 1 to right_F1_axis/f1_lines_every
        lab = i*f1_lines_every/1000
        if i*f1_lines_every > left_F1_axis and i*f1_lines_every < right_F1_axis
          One mark right: -(i*f1_lines_every), "no", "no", "yes", ""
        endif
      endfor
    endif
    for i from 1 to right_F1_axis/f1_labels_every
      lab = i*f1_labels_every/1000 
      if i*f1_labels_every > left_F1_axis and i*f1_labels_every <= right_F1_axis
        One mark right: -(i*f1_labels_every), "no", "yes", "no", "'lab'"
      endif
    endfor
    # for lower limit
    if label_lower_limits = 1
      lab = left_F2_axis/1000
      One mark top: -(left_F2_axis), "no", "yes", "no", "'lab'"
      lab = left_F1_axis/1000
      One mark right: -(left_F1_axis), "no", "yes", "no", "'lab'"
    endif
  endif
  # draw a vowel
  if f1 <> 0 and f2 <> 0
    Text: -(f2), "Centre", -(f1), "Half", "'symbol$'"
  endif
  # draw an arrow
  if left_from <> 0 and right_from <> 0 and left_to <> 0 and left_to <> 0
    if line_style = 1
      Draw line: -right_from, -left_from, -right_to, -left_to
    elsif line_style = 2
      Draw arrow: -right_from, -left_from, -right_to, -left_to
    elsif line_style = 3
      Draw two-way arrow: -right_from, -left_from, -right_to, -left_to
    endif
  endif

elsif type_of_plot = 2
  # sets the axes
  lx = log10(left_F2_axis)
  rx = log10(right_F2_axis)
  ty = log10(left_F1_axis)
  by = log10(right_F1_axis)
  Axes: -rx, -lx, -by, -ty
  # does the drawing
  if garnish = 1
    # draws the box
    Draw inner box
    # labels the axes
    Text top: "yes", "F2 (kHz)"
    Text right: "yes", "F1 (kHz)"
    # labels F2 axis
    if f2_lines_every <> 0
      for i from 1 to right_F2_axis/f2_lines_every
        lab = i*f2_lines_every/1000
        if i*f2_lines_every > left_F2_axis and i*f2_lines_every < right_F2_axis
          One mark top: -log10(i*f2_lines_every), "no", "no", "yes", ""
        endif
      endfor
    endif
    for i from 1 to right_F2_axis/f2_labels_every
      lab = i*f2_labels_every/1000 
      if i*f2_labels_every > left_F2_axis and i*f2_labels_every <= right_F2_axis
        One mark top: -log10(i*f2_labels_every), "no", "yes", "no", "'lab'"
      endif
    endfor
    # labels F1 axis
    if f1_lines_every <> 0
      for i from 1 to right_F1_axis/f1_lines_every
        lab = i*f1_lines_every/1000
        if i*f1_lines_every > left_F1_axis and i*f1_lines_every < right_F1_axis
          One mark right: -log10(i*f1_lines_every), "no", "no", "yes", ""
        endif
      endfor
    endif
    for i from 1 to right_F1_axis/f1_labels_every
      lab = i*f1_labels_every/1000 
      if i*f1_labels_every > left_F1_axis and i*f1_labels_every <= right_F1_axis
        One mark right: -log10(i*f1_labels_every), "no", "yes", "no", "'lab'"
      endif
    endfor
    # for lower limit
    if label_lower_limits = 1
      lab = left_F2_axis/1000
      One mark top: -log10(left_F2_axis), "no", "yes", "no", "'lab'"
      lab = left_F1_axis/1000
      One mark right: -log10(left_F1_axis), "no", "yes", "no", "'lab'"
    endif
  endif
  # draw a vowel
  if f1 <> 0 and f2 <> 0
    Text: -log10(f2), "Centre", -log10(f1), "Half", "'symbol$'"
  endif
  # draw an arrow
  if left_from <> 0 and right_from <> 0 and left_to <> 0 and left_to <> 0
    if line_style = 1
      Draw line: -log10(right_from), -log10(left_from), -log10(right_to), -log10(left_to)
    elsif line_style = 2
      Draw arrow: -log10(right_from), -log10(left_from), -log10(right_to), -log10(left_to)
    elsif line_style = 3
      Draw two-way arrow: -log10(right_from), -log10(left_from), -log10(right_to), -log10(left_to)     
    endif
  endif
endif