# drawReactionData.praat. Praat script to prepare visual representations of the
# times of listeners' reactions to audio samples. See sepate documentation file.

# possible to do list:
# . drawing filled bars?
# . option to draw pitch?
# . draw TextGrid/labels as a panel?
# . plot responses as a percentage of some total number

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

table = selected ("Table")

##### Working on the selected objects

# get number of selected Objects
selObjects = numberOfSelected ()
# get IDs of selected Objects
n = numberOfSelected ()
for i to selObjects
  numberID [i] = selected (-i)
endfor

# get number of each type of selected object
selTable = numberOfSelected ("Table")
selSound = numberOfSelected ("Sound")
selSpectrogram = numberOfSelected ("Spectrogram")
if (selTable > 1 or selSound > 1 or selSpectrogram > 1)
  exitScript: "You have more than one object of the same
    ... type selected. Check your selection and try again."
endif

# check everything can be drawn
objToDraw = selTable + selSound + selSpectrogram
if objToDraw < selObjects
  exitScript: "You have at least one Object selected which can't
  ... be drawn with this script. Check your selection and try again."
endif

# get object IDs
if selTable = 1
  table = selected ("Table")
endif
if selSound = 1
  sound = selected ("Sound")
endif
if selSpectrogram = 1
  spectrogram = selected ("Spectrogram")
endif

# get name of table
table_name$ = selected$ ("Table")

##### Dialogue box etc.

form: "Draw reaction data..."
  sentence: "Column_containing_times", "time"
  real: "left_Time_range_(s)", "0"
  positive: "right_Time_range", "10"
  positive: "Bin_width_(s)", "0.5"
  positive: "Jump_size_(s)", "0.1"
  positive: "Mark_x_axis_every", "1"
  positive: "Mark_y_axis_every", "10"
  real: "left_Y_axis_range", "0"
  real: "right_Y_axis_range", "0 (= all)"
  sentence: "Y_axis_label", "responses (%n)"
  real: "left_Spectrogram_range_(Hz)", "0"
  real: "right_Spectrogram_range", "0 (= all)"
  real: "Spectrogram_dynamic_range_(dB)", "50"
  real: "Mark_spectrogram_every_(kHz)", "1"
  optionmenu: "Style", "2"
    option: "bars"
    option: "lines"
    option: "points"
    option: "lines and points"
    option: "none (just draw the border)"
  real: "Line_width", "1"
  real: "Point_size_(mm)", "0.05"
  optionmenu: "Colour", "1"
    option: "Black"
    option: "White"
    option: "Red"
    option: "Green"
    option: "Blue"
    option: "Yellow"
    option: "Cyan"
    option: "Magenta"
    option: "Maroon"
    option: "Lime"
    option: "Navy"
    option: "Teal"
    option: "Purple"
    option: "Olive"
    option: "Pink"
    option: "Silver"
    option: "Grey"
  optionmenu: "Line_style", "1"
    option: "Solid line"
    option: "Dotted line"
    option: "Dashed line"
    option: "Dashed-dotted line"
  boolean: "Garnish", "on"
  boolean: "Just_reaction_times", "off"
  boolean: "Erase_all", "on"
  boolean: "Save_data_to_desktop", "off"
endform

start_time = left_Time_range
end_time = right_Time_range
time_col$ = column_containing_times$

spec_min = left_Spectrogram_range
spec_max = right_Spectrogram_range

bin_start = start_time - (bin_width)
bin_end = bin_start + bin_width

if colour = 1
  colour$ = "Black"
elsif colour = 2
  colour$ = "White"
elsif colour = 3
  colour$ = "Red"
elsif colour = 4
  colour$ = "Green"
elsif colour = 5
  colour$ = "Blue"
elsif colour = 6
  colour$ = "Yellow"
elsif colour = 7
  colour$ = "Cyan"
elsif colour = 8
  colour$ = "Magenta"
elsif colour = 9
  colour$ = "Maroon"
elsif colour = 10
  colour$ = "Lime"
elsif colour = 11
  colour$ = "Navy"
elsif colour = 12
  colour$ = "Teal"
elsif colour = 13
  colour$ = "Purple"
elsif colour = 14
  colour$ = "Olive"
elsif colour = 15
  colour$ = "Pink"
elsif colour = 16
  colour$ = "Silver"
elsif colour = 17
  colour$ = "Grey"
endif

##### Warnings

# check that bin_width is a factor of the material to be plotted
number_of_bins = (start_time - end_time)/bin_width
number_of_bins_rnd = round(number_of_bins)
if number_of_bins <> number_of_bins_rnd
  exitScript: "The bin width is not a factor of the material to be plotted."
endif

# check jump size and bin width
if jump_size < bin_width and style = 1
  pauseScript: "Bin width is greater than jump size. Bars may overlap."
elsif jump_size > bin_width
  pauseScript: "Jump size is greater than bin width. Some data may not be represented."  
endif

##### Create data table

new_Table = Create Table with column names: "table", 0, {"bin_start","bin_end","count"}

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
until bin_start + (0.5*(bin_end - bin_start)) > end_time

if save_data_to_desktop = 1
  Save as comma-separated file: "~/Desktop/" + table_name$ + "-reactions.csv"
endif

##### Drawing procedures

# to get original viewport (used as a reference point)
procedure getOrigViewport
  opicInfo$ = Picture info
  ovpLeft = extractNumber(opicInfo$, "Inner viewport left:")
  ovpRight = extractNumber(opicInfo$, "Inner viewport right:")
  ovpTop = extractNumber(opicInfo$, "Inner viewport top:")
  ovpBottom = extractNumber(opicInfo$, "Inner viewport bottom:")
endproc

# to select original viewport
procedure selectOrigViewport
  Select inner viewport: ovpLeft, ovpRight, ovpTop, ovpBottom
endproc

# get current viewport
procedure getViewport
  curr_picInfo$ = Picture info
  curr_vpLeft = extractNumber(curr_picInfo$, "Inner viewport left:")
  curr_vpRight = extractNumber(curr_picInfo$, "Inner viewport right:")
  curr_vpTop = extractNumber(curr_picInfo$, "Inner viewport top:")
  curr_vpBottom = extractNumber(curr_picInfo$, "Inner viewport bottom:")
endproc

# line style
procedure line_style
  if line_style = 1
    Solid line
  elsif line_style = 2
    Dotted line
  elsif line_style = 3
    Dashed line
  elsif line_style = 4
    Dashed-dotted line
  endif
endproc

procedure drawHits
  Colour: colour$
  Line width: line_width
  @line_style
  if style = 1
    Draw rectangle: x_val_start, x_val_end, 0, y_val
  elsif style = 2
    if q > 1
      prev_bin_start =  Get value: q-1, "bin_start" 
      line_start_x = (bin_width/2)+prev_bin_start
      line_start_y = Get value: q-1, "count" 
      curr_bin_start = Get value: q, "bin_start" 
      line_end_x = curr_bin_start + (bin_width/2)
      line_end_y = y_val
      Draw line: line_start_x,line_start_y,line_end_x,line_end_y
    endif
  elsif style = 3
    Paint circle: colour$,x_val_start+(bin_width/2),y_val,point_size
  elsif style = 4
    if q > 1
      prev_bin_start =  Get value: q-1, "bin_start" 
      line_start_x = (bin_width/2)+prev_bin_start
      line_start_y = Get value: q-1, "count" 
      curr_bin_start = Get value: q, "bin_start" 
      line_end_x = curr_bin_start + (bin_width/2)
      line_end_y = y_val
      Draw line: line_start_x,line_start_y,line_end_x,line_end_y
      Paint circle: colour$,x_val_start+(bin_width/2),y_val,point_size
    endif
  endif
  Colour: origColour$
  'origLineType$' line
  Line width: 'origLineWidth$'
endproc

procedure drawSound
  selectObject: sound
  Draw: start_time, end_time, 0, 0, "no", "curve"
  Draw inner box
endproc

procedure freqMarks
    fDist = mark_spectrogram_every
    Marks right every: 1000, fDist, "yes", "yes", "no"
endproc

procedure drawSpectrogram
  selectObject: spectrogram
  Paint: start_time, end_time, left_Spectrogram_range, right_Spectrogram_range, 100, "yes", spectrogram_dynamic_range, 6, 0, "no"
  Draw inner box
  @freqMarks
  Text right: "yes", "Frequency (kHz)"
endproc

##### Draw the plot

# gets the current line settings
picInfo$ = Picture info
origLineType$ = extractLine$(picInfo$, "Line type: ")
origLineTypeFull$ = origLineType$ + " line"
origLineWidth$ = extractLine$(picInfo$, "Line width: ")
origColour$ = extractLine$(picInfo$, "Colour: ")

# find out the proportions for the panels

if selTable = 1 and selSpectrogram = 0 and selSound = 0
  tableProp = 1/1
elsif selTable = 1 and selSpectrogram = 0 and selSound = 1
  tableProp = 2/3
  soundProp = 1/3
elsif selTable = 1 and selSpectrogram = 1 and selSound = 0
  tableProp = 1/2
  spectrogramProp = 1/2
elsif selTable = 1 and selSpectrogram = 1 and selSound = 1
  tableProp = 2/5
  spectrogramProp = 2/5
  soundProp = 1/5
endif

# draw the table

if erase_all = 1
  Erase all
endif

@getOrigViewport

tablePlotHeight = (ovpBottom-ovpTop)*tableProp
Select inner viewport: ovpLeft, ovpRight, ovpBottom-tablePlotHeight, ovpBottom

if left_Y_axis_range = 0 and right_Y_axis_range = 0
  selectObject: new_Table
  y_min = left_Y_axis_range
  y_max = Get maximum: "count"
else
  y_min = left_Y_axis_range  
  y_max = right_Y_axis_range
endif

new_Table_rows = Get number of rows
Axes: start_time, end_time, y_min, y_max

for q to new_Table_rows
  x_val_start = Get value: q, "bin_start"
  x_val_end = Get value: q, "bin_end"
  y_val = Get value: q, "count"
  if y_val >= y_min and x_val_start + (bin_width/2) >= start_time + jump_size ; and x_val_end <= end_time
    @drawHits
  endif
endfor

# garnishing
if garnish = 1
  Draw inner box
  Marks bottom every: 1, mark_x_axis_every, "yes", "yes", "no"
  Text bottom: "yes", "Time (s)"
  Marks left every: 1, mark_y_axis_every, "yes", "yes", "no"
  Text left: "yes", y_axis_label$
endif

@selectOrigViewport

# draw any other panels, if selected

if just_reaction_times = 0
  if selSound = 1 and selSpectrogram = 0
    soundPlotHeight = (ovpBottom-ovpTop)*soundProp
    Select inner viewport: ovpLeft, ovpRight, ovpTop, ovpTop+soundPlotHeight
    @drawSound
  endif

  if selSound = 0 and selSpectrogram = 1
    spectrogramPlotHeight = (ovpBottom-ovpTop)*spectrogramProp
    Select inner viewport: ovpLeft, ovpRight, ovpTop, ovpTop+spectrogramPlotHeight
    @drawSpectrogram
  endif

  if selSound = 1 and selSpectrogram = 1
    spectrogramPlotHeight = (ovpBottom-ovpTop)*spectrogramProp
    soundPlotHeight = (ovpBottom-ovpTop)*soundProp
    Select inner viewport: ovpLeft, ovpRight, ovpTop, ovpTop+soundPlotHeight
    @drawSound
    Select inner viewport: ovpLeft, ovpRight, ovpTop+soundPlotHeight, ovpTop+soundPlotHeight+spectrogramPlotHeight
    @drawSpectrogram
  endif

endif

@selectOrigViewport

# clean up
selectObject: new_Table
Remove

selectObject ()
for i from 1 to n
  plusObject: numberID [i]
endfor
