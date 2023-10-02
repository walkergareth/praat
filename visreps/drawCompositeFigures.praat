# drawCompositeFigures.praat. Praat script to draw combinations and
# displays based on selected Objects (Sound, Spectrogram, TextGrid
# Pitch, Formant, Intensity).

# See the following for discussion:

# Walker, G. (2017). Visual representations of acoustic data: A survey
# and suggestions. Research on Language and Social Interaction, 50(4),
# 363–387. https://doi.org/10.1080/08351813.2017.1375802

# (open access version available at https://eprints.whiterose.ac.uk/116941/)

# 26 January 2023 - updated form to new syntax (Praat v. 6.3.04)
# 25 January 2022 - Made minor and major marks look different from each other;
#                   introduced option to show x axis marks along the top
# 7 February 2018 - Added option for minor marks on the x axis
# 6 February 2018 - Fixed garnishing of Formant objects; improved Spectrogram axis labels
# 5 February 2018 - Added option to draw Sound objects at half height
#                   when drawing multiple panels

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

#################
#
# Drawing options
#
#################

form: "Drawing options"
  real: "left_Time_range_(s)", "0"
  real: "right_Time_range", "0 (= all)"
  real: "Major_mark_x_axis_every_(s)", "1"
  real: "Minor_mark_x_axis_every_(s)", "0 (= none)"
  real: "Height_of_text_tier", "1.5"
  real: "left_Pitch_range_(Hz)", "50"
  real: "right_Pitch_range", "500"
  real: "Pitch_middle_(Hz)", "0 (= none)"
  optionmenu: "Pitch_style:", "2"
    option: "Speckle linear (Hz)"
    option: "Speckle logarithmic (Hz)"
    option: "Speckle semitones (re baseline)"
    option: "Draw linear (Hz)"
    option: "Draw logarithmic (Hz)"
    option: "Draw semitones (re baseline)"
    option: "Speckle linear pitch and loudness (Hz)"
    option: "Speckle logarithmic pitch and loudness (Hz)"
    option: "Speckle semitones pitch and loudness (re baseline)"
  real: "left_Intensity_range_(dB)", "0"
  real: "right_Intensity_range", "0 (= all)"
  real: "left_Spectrogram_range_(Hz)", "0"
  real: "right_Spectrogram_range", "0 (= all)"
  real: "Spectrogram_dynamic_range_(dB)", "50"
  real: "Maximum_formant_frequency_(Hz)", "5000"
  real: "Formant_dynamic_range_(dB)", "30"
  real: "Pitch_and_loudness_dynamic_range_(dB)", "20"
  boolean: "Show_TextGrid_boundaries", "1"
  boolean: "Mirror_x_axis_labels", "0"
  boolean: "Mark_zero_crossing", "off"
  boolean: "Save_picture_to_file_on_desktop", "off"
  boolean: "Erase_all", "on"
  boolean: "Draw_Sound_halfsize_(if_panels_>1)", "on"
endform

#################################
# 
# Working on the selected objects
#
#################################

# get number of selected Objects
selObjects = numberOfSelected ()
# get IDs of selected Objects
n = numberOfSelected ()
for i to selObjects
  numberID [i] = selected (-i)
endfor
# get number of each type of selected object
selSound = numberOfSelected ("Sound")
selTextGrid = numberOfSelected ("TextGrid")
selPitch = numberOfSelected ("Pitch")
selIntensity = numberOfSelected ("Intensity")
selSpectrogram = numberOfSelected ("Spectrogram")
selFormant = numberOfSelected ("Formant")
# check for Pitch and Intensity if drawing pitch and loudness
if (selIntensity = 0 or selPitch = 0) and pitch_style >= 7
  exitScript: "You need to select a Pitch object and an Intensity
    ... object to draw pitch and loudness. Change your selection and try again."
endif
# check a relevant Object is selected types
if selSound + selTextGrid + selPitch + selIntensity + selSpectrogram + selFormant = 0
  exitScript: "You have not selected any objects which this script can draw. 
    ... Change your selection and try again."
endif
# check for duplicates of Object types
if selSound > 1 or selTextGrid > 1 or selPitch > 1 or
    ... selIntensity > 1 or selSpectrogram > 1 or selFormant > 1
  exitScript: "You have selected more than one object of the same type. 
    ... Change your selection and try again."
endif
# check everything can be drawn
objToDraw = selSound + selTextGrid + selPitch 
  ... + selIntensity + selSpectrogram + selFormant
if objToDraw < selObjects
  exitScript: "You have at least one object selected which can't
  ... be drawn with this script. 
  ... Check your selection and try again."
endif
# get object IDs
if selSound = 1
  sound = selected ("Sound")
endif
if selTextGrid = 1
  textGrid = selected ("TextGrid")
endif
if selPitch = 1
  pitch = selected ("Pitch")
endif
if selIntensity = 1
  intensity = selected ("Intensity")
endif
if selSpectrogram = 1
  spectrogram = selected ("Spectrogram")
endif
if selFormant = 1
  formant = selected ("Formant")
endif
# number of tiers in a TextGrid
if selTextGrid > 0
  selectObject: textGrid
  tiers = Get number of tiers
endif
# how many panels are needed
specPanel = 0
prosPanel = 0
soundPanel = 0
if selFormant = 1 or selSpectrogram = 1
  specPanel = 1
endif
if selPitch = 1 or selIntensity = 1
  prosPanel = 1
endif
if selSound = 1
  soundPanel = 1
endif
panels = specPanel + prosPanel + soundPanel
# gets the spectrogram maximum
if selSpectrogram = 1 
  selectObject: spectrogram
  specInfo$ = Info
  specMax = extractNumber(specInfo$, "Highest frequency:")
  if right_Spectrogram_range <> 0
    specMax = right_Spectrogram_range
  endif
endif
# checks that spectrogram maximum and formant maximum are the same before drawing
if selFormant = 1 and selSpectrogram = 1
  if left_Spectrogram_range <> 0
    beginPause: "Warning!"
      comment: "Bottom of spectrogram is different from bottom of formant range (0 Hz)."
      comment: "Axis labels will match spectrogram."
      clicked = endPause: "Cancel", "Continue", 2, 1
      if clicked = 1
        @selectOriginal
        exitScript ()
      endif
  endif 
  if maximum_formant_frequency <> specMax
    beginPause: "Warning!"
      comment: "Top of formant range and top of spectrogram are different."
      comment: "Axis labels will match spectrogram."
      clicked = endPause: "Cancel", "Continue", 2, 1
      if clicked = 1
        @selectOriginal
        exitScript ()
      endif
  endif
endif
# gets the intensity maximum and minimum
if selIntensity = 1 
  selectObject: intensity
  intMin = left_Intensity_range
  intMax = right_Intensity_range
  if intMin = 0 and intMax = 0
    intMin = Get minimum: left_Time_range, right_Time_range, "Parabolic"
    intMax = Get maximum: left_Time_range, right_Time_range, "Parabolic"
  endif
  intRange = intMax - intMin
  if intRange <= 5
    intMarks = 1
  elsif intRange <= 10
    intMarks = 2
  elsif intRange <= 20
    intMarks = 5
  elsif intRange <= 40
    intMarks = 10
  elsif intRange <= 100
    intMarks = 20
  else
    intMarks = 50
  endif
endif
# gets number of frames in a Pitch object 
if selPitch = 1
  selectObject: pitch
  frames = Get number of frames
endif
# checks the major and minor axis tics
if minor_mark_x_axis_every > 0
  if major_mark_x_axis_every/minor_mark_x_axis_every <> round(major_mark_x_axis_every/minor_mark_x_axis_every)
    beginPause: "Warning!"
      comment: "Major marks on the x axis are not multiples of the minor marks."
      comment: "X axis labels will look strange."
      clicked = endPause: "Cancel", "Continue", 2, 1
      if clicked = 1
        @selectOriginal
        exitScript ()
      endif
  endif
endif

###############################
#
# Processing of drawing options
#
###############################

if show_TextGrid_boundaries = 1
  boundaries$ = "yes"
elsif show_TextGrid_boundaries = 0
  boundaries$ = "no"
endif
selectObject: numberID[1]
startTime = Get start time
endTime = Get end time
if left_Time_range = 0
  left_Time_range = startTime
endif
if right_Time_range = 0
  right_Time_range = endTime
endif
# gets the current line width setting
picInfo$ = Picture info
origLineType$ = extractLine$(picInfo$, "Line type: ")
speckleSize = extractNumber(picInfo$, "Speckle size:")
colour$ = extractLine$(picInfo$, "Colour: ")
if erase_all = 1
  Erase all
endif

########################
# 
# Procedures for drawing
#
########################

# draw spectrogram
procedure drawSpectrogram
  selectObject: spectrogram
  Paint: left_Time_range, right_Time_range, left_Spectrogram_range, right_Spectrogram_range, 100, "yes", spectrogram_dynamic_range, 6, 0, "no"
  @freqMarks
  Text left: "yes", "Frequency (kHz)"
endproc
# draw intensity
procedure drawIntensity
  selectObject: intensity
  Draw: left_Time_range, right_Time_range, left_Intensity_range, right_Intensity_range, "no"
endproc
# garnish intensity
procedure garnishIntensity
  Marks left every: 1, intMarks, "yes", "yes", "no"
  Text left: "yes", "Intensity (dB)"
endproc
# for when intensity is drawn with pitch
procedure garnishIntensityRight
  Marks right every: 1, intMarks, "yes", "yes", "no"
  Text right: "yes", "Intensity (dB)"
endproc
# draw formants
procedure drawFormant
  selectObject: formant
  Speckle: left_Time_range, right_Time_range, maximum_formant_frequency, formant_dynamic_range, "no"
  White
  Speckle size: speckleSize-0.5
  Speckle: left_Time_range, right_Time_range, maximum_formant_frequency, formant_dynamic_range, "no"
  Speckle size: speckleSize
  Colour: colour$
endproc
# garnish formants (do this if spectrogram hasn't been drawn)
procedure garnishFormant
  @freqMarks
  Text left: "yes", "Frequency (kHz)"
endproc
# draw sound
procedure drawSound
  selectObject: sound
  Draw: left_Time_range, right_Time_range, 0, 0, "no", "Curve"
  if mark_zero_crossing = 1
    Dotted line
      Draw line: left_Time_range, 0, right_Time_range, 0
    'origLineType$' line
  endif
endproc
# labels for pitch y-axis
procedure pitchYAxis
  pitchRange = right_Pitch_range - left_Pitch_range
  if pitchRange <= 125
    pitchLabInt = 25
  elsif pitchRange <= 250
    pitchLabInt = 50
  elsif pitchRange <= 400
    pitchLabInt = 100
  elsif pitchRange > 400
    pitchLabInt = 150
  endif
  if pitch_style = 1 or pitch_style = 4 or pitch_style = 7
    One mark left: 'left_Pitch_range', "no", "yes", "no", "'left_Pitch_range:0'"
    if pitch_middle <> 0 
       One mark left: pitch_middle, "no", "no", "yes", ""
    endif
  elsif pitch_style = 2 or pitch_style = 5 or pitch_style = 8
    One logarithmic mark left: 'left_Pitch_range', "no", "yes", "no", "'left_Pitch_range:0'"
    if pitch_middle <> 0 
       One logarithmic mark left: pitch_middle, "no", "no", "yes", ""
    endif
  endif
  rndPitchBottom = (ceiling(left_Pitch_range/pitchLabInt))*pitchLabInt
  pitchMark = pitchLabInt
  if (rndPitchBottom - left_Pitch_range) > (pitchMark / 2)
    pitchMark = pitchLabInt
  else 
    pitchMark = pitchLabInt + rndPitchBottom
  endif
  repeat
    if pitchMark > left_Pitch_range
      if pitch_style = 1 or pitch_style = 4 or pitch_style = 7
        One mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
      elsif pitch_style = 2 or pitch_style = 5 or pitch_style = 8
        One logarithmic mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
      endif
    endif
    pitchMark = pitchMark + pitchLabInt
    until pitchMark >= right_Pitch_range
    # add another mark if there is no Spectrogram or Formant track
    if specPanel = 0 and pitchMark <= right_Pitch_range
      if pitch_style = 1 or pitch_style = 4 or pitch_style = 7
        One mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
      elsif pitch_style = 2 or pitch_style = 5 or pitch_style = 8
        One logarithmic mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
      endif
    endif
  endif
endproc
# draw pitch and loudness
procedure drawPitchLoudness
  intTab = Create Table with column names: "'pitch'-pitchloudness", frames, "time pitch intensity"
  if pitch_style = 7
    Axes: left_Time_range, right_Time_range, left_Pitch_range, right_Pitch_range
  elsif pitch_style = 8
    Axes: left_Time_range, right_Time_range, log10(left_Pitch_range), log10(right_Pitch_range)
  elsif pitch_style = 9
    top = 12*log2(right_Pitch_range/left_Pitch_range)
    Axes: left_Time_range, right_Time_range, 12*log2(left_Pitch_range/left_Pitch_range), top
  endif
  for z to frames
    selectObject: pitch
    frametime = Get time from frame number: z
    framepitch = Get value in frame: z, "Hertz"
    selectObject: intensity
    frameintensity = Get value at time: frametime, "Cubic"
    selectObject: intTab
    Set numeric value: z, "time", frametime
    if framepitch <> undefined
      Set numeric value: z, "pitch", framepitch
    endif
    if frameintensity <> undefined and frameintensity >= intMax - pitch_and_loudness_dynamic_range
      Set numeric value: z, "intensity", frameintensity
    endif
    circlecolor = ((intMax-frameintensity)*(1/pitch_and_loudness_dynamic_range))
    if framepitch <> undefined and frameintensity <> undefined and circlecolor > 0 and circlecolor < 1
      if pitch_style = 7
        Paint circle (mm): circlecolor, frametime, framepitch, speckleSize
      elsif pitch_style = 8
        Paint circle (mm): circlecolor, frametime, log10(framepitch), speckleSize
      elsif pitch_style = 9
        Paint circle (mm): circlecolor, frametime, 12*log2(framepitch/left_Pitch_range), speckleSize
      endif
    endif
  endfor
  selectObject: intTab
  Remove
endproc
# label semitones
procedure stLabs
  if top > 36
    stLabelsEvery = 12
  elsif top <= 36
    stLabelsEvery = 6
  endif
  pitchMark = 0
  repeat
    if pitchMark < left_Pitch_range
        One mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
    endif
    pitchMark = pitchMark + stLabelsEvery
    until pitchMark >= 12*log2(right_Pitch_range/left_Pitch_range)
    # add another mark if there is no Spectrogram or Formant track
    if specPanel = 0 and pitchMark <= 12*log2(right_Pitch_range/left_Pitch_range)
        One mark left: pitchMark, "no", "yes", "no", "'pitchMark'"
    endif
  if pitch_middle <> 0 
     One mark left: 12*log2(pitch_middle/left_Pitch_range), "no", "no", "yes", ""
  endif
  Text left: "yes", "Pitch (ST %%re% baseline)"
endproc
# draw pitch
procedure drawPitch
  selectObject: pitch
  if pitch_style = 1
    Speckle: left_Time_range, right_Time_range, left_Pitch_range, right_Pitch_range, "no"
  elsif pitch_style = 2
    Speckle logarithmic: left_Time_range, right_Time_range, left_Pitch_range, right_Pitch_range, "no"
  elsif pitch_style = 4
    Draw: left_Time_range, right_Time_range, left_Pitch_range, right_Pitch_range, "no"
  elsif pitch_style = 5
    Draw logarithmic: left_Time_range, right_Time_range, left_Pitch_range, right_Pitch_range, "no"
  elsif pitch_style = 3 or pitch_style = 6
    top = 12*log2(right_Pitch_range/left_Pitch_range) 
    copy_st = Copy: "'pitch'ST"
    Formula: "12*log2(self/left_Pitch_range)"
    if pitch_style = 3
      Speckle: left_Time_range, right_Time_range, 0, top, "no"
    elsif pitch_style = 6
      Draw: left_Time_range, right_Time_range, 0, top, "no"
    endif
    selectObject: copy_st
    Remove
  elsif pitch_style >= 7
    @drawPitchLoudness
  endif
  if pitch_style = 1 or pitch_style = 2 or pitch_style = 4 or pitch_style = 5 or pitch_style = 7 or pitch_style = 8
    @pitchYAxis
    Text left: "yes", "Pitch (Hz)"
  elsif pitch_style = 3 or pitch_style = 6 or pitch_style = 9
    @stLabs 
  endif
endproc
# draw TextGrid
procedure drawTextGrid
  selectObject: textGrid
  Draw: left_Time_range, right_Time_range, boundaries$, "yes", "no"
endproc
# final garnishing
procedure finalGarnish
  Draw inner box
  info$ = Picture info
  axisLeft = extractNumber (info$, "Axis left: ") 
  axisRight = extractNumber (info$, "Axis right: ")
  axisBottom = extractNumber (info$, "Axis bottom: ")
  axisTop = extractNumber (info$, "Axis top: ") 
  Axes: axisLeft, axisRight, 0, 1
  if minor_mark_x_axis_every > 0
    minorMarkBottom = (round(left_Time_range/minor_mark_x_axis_every))*minor_mark_x_axis_every
    Line width: 2
    repeat
      if minorMarkBottom >= left_Time_range
        Draw line: minorMarkBottom, -0.0075, minorMarkBottom, 0
        if mirror_x_axis_labels = 1
          Draw line: minorMarkBottom, 1.0075, minorMarkBottom, 1
        endif
      endif
      minorMarkBottom = minorMarkBottom + minor_mark_x_axis_every
    until 'minorMarkBottom:14' > right_Time_range
    Line width: 1
  endif
  if major_mark_x_axis_every > 0
    majorMarkBottom = (round(left_Time_range/major_mark_x_axis_every))*major_mark_x_axis_every
    Line width: 2
    repeat
      if majorMarkBottom >= left_Time_range
        Draw line: majorMarkBottom, -0.015, majorMarkBottom, 0
        majorMarkBottomRnd = 'majorMarkBottom:14'
        majorMarkBottom$ = string$ (majorMarkBottomRnd)
        Text: majorMarkBottom, "centre", -0.015, "top", majorMarkBottom$
        if mirror_x_axis_labels = 1
          Draw line: majorMarkBottom, 1.015, majorMarkBottom, 1
          Text: majorMarkBottom, "centre", 1, "bottom", majorMarkBottom$
        endif
      endif
      majorMarkBottom = majorMarkBottom + major_mark_x_axis_every
    until 'majorMarkBottom:14' > right_Time_range
    Line width: 1
  endif
  Axes: axisLeft, axisRight, axisBottom, axisTop
  Text bottom: "yes", "Time (s)"
endproc

# viewport information
procedure getOrigViewport
  opicInfo$ = Picture info
  oivpLeft = extractNumber(opicInfo$, "Inner viewport left:")
  oivpRight = extractNumber(opicInfo$, "Inner viewport right:")
  oivpTop = extractNumber(opicInfo$, "Inner viewport top:")
  oivpBottom = extractNumber(opicInfo$, "Inner viewport bottom:")
endproc
# get current viewport
procedure getViewport
  picInfo$ = Picture info
  ivpLeft = extractNumber(picInfo$, "Inner viewport left:")
  ivpRight = extractNumber(picInfo$, "Inner viewport right:")
  ivpTop = extractNumber(picInfo$, "Inner viewport top:")
  ivpBottom = extractNumber(picInfo$, "Inner viewport bottom:")
endproc
# get drawing viewport
procedure getDrawingViewport
  dpicInfo$ = Picture info
  divpLeft = extractNumber(dpicInfo$, "Inner viewport left:")
  divpRight = extractNumber(dpicInfo$, "Inner viewport right:")
  divpTop = extractNumber(dpicInfo$, "Inner viewport top:")
  divpBottom = extractNumber(dpicInfo$, "Inner viewport bottom:")
endproc

# size of panels
procedure topHalf
  Select inner viewport: divpLeft, divpRight, divpTop, divpTop+((divpBottom-divpTop)/2)
endproc
procedure bottomHalf
  Select inner viewport: divpLeft, divpRight, divpTop+((divpBottom-divpTop)/2), divpBottom
endproc
procedure topThird
  Select inner viewport: divpLeft, divpRight, divpTop, divpTop+((divpBottom-divpTop)/3)
endproc
procedure middleThird
  Select inner viewport: divpLeft, divpRight, divpTop+((divpBottom-divpTop)/3), divpTop+(((divpBottom-divpTop)/3)*2)
endproc
procedure bottomThird
  Select inner viewport: divpLeft, divpRight, divpTop+(((divpBottom-divpTop)/3)*2), divpBottom
endproc
# panel sizes for halfsize Sound 
procedure halfAgain
  @getDrawingViewport
  Select inner viewport: divpLeft, divpRight, divpTop, divpTop+((divpBottom-divpTop)/2)
endproc
procedure increaseByHalf
  @getDrawingViewport
  Select inner viewport: divpLeft, divpRight, divpTop, divpBottom+((divpBottom-divpTop)*2)
endproc
procedure topThirdHalf
  Select inner viewport: divpLeft, divpRight, divpTop, divpTop+((divpBottom-divpTop)*(1/5))
endproc
procedure middleThirdPlus
  Select inner viewport: divpLeft, divpRight, divpTop+((divpBottom-divpTop)*(1/5)), divpTop+((divpBottom-divpTop)*(3/5))
endproc
procedure bottomThirdPlus
  Select inner viewport: divpLeft, divpRight, divpTop+((divpBottom-divpTop)*(3/5)), divpBottom
endproc

# for drawing lines between panels
procedure drawLine
  Solid line
  Axes: left_Time_range, right_Time_range, 0, 1
  Draw line: left_Time_range, 0, right_Time_range, 0 
  'origLineType$' line
endproc
# marks on spectrograms
procedure freqMarks
  if selSpectrogram = 1
     freqMax = specMax
  elsif selSpectrogram = 0 and selFormant = 1
     freqMax = maximum_formant_frequency
  endif
  if freqMax > 6000
     fDist = 2
  else
     fDist = 1
  endif
  if panels > 1 and prosPanel = 1
    fMark = 1
    repeat
      freqLab = fMark*fDist
      One mark left: (fDist*1000)*fMark, "no", "yes", "no", "'freqLab'"
      fMark = fMark + 1
    until (fDist*1000)*fMark > freqMax
  else
    Marks left every: 1000, fDist, "yes", "yes", "no"
  endif
endproc
procedure selectOriginal
  selectObject ()
  for i from 1 to n
    plusObject: numberID [i]
  endfor
endproc

##########
#
# Drawings
#
##########

@getOrigViewport

# draw TextGrid labels
if selTextGrid = 1
  @getViewport
  axisTop = extractNumber(picInfo$, "Axis top:")
  axisBottom = extractNumber(picInfo$, "Axis bottom:")
  Select inner viewport: ivpLeft, ivpRight, (ivpBottom-ivpTop)/height_of_text_tier, ivpBottom
  selectObject: textGrid
  Draw: left_Time_range, right_Time_range, "no", "no", "no"
  newpicInfo$ = Picture info
  newIvpTop = extractNumber(newpicInfo$, "Inner viewport top:")
  newIvpBottom = extractNumber(newpicInfo$, "Inner viewport bottom:")
  topOfTG = (tiers/(tiers+4)) * (newIvpBottom - newIvpTop)
  Select inner viewport: oivpLeft, oivpRight, oivpTop, oivpBottom-topOfTG
endif

@getDrawingViewport

# if there is one panel to draw
if panels = 1
  if selSound = 1
    @drawSound
  elsif selSpectrogram = 1 and selFormant = 0
    @drawSpectrogram
  elsif selSpectrogram = 1 and selFormant = 1
    @drawSpectrogram
    @drawFormant
  elsif selSpectrogram = 0 and selFormant = 1
    @drawFormant
    @garnishFormant
  elsif selPitch = 1 and selIntensity = 0
    @drawPitch
  elsif selIntensity = 1 and selPitch = 0
    @drawIntensity
    @garnishIntensity
  elsif selIntensity = 1 and selPitch = 1
    @drawPitch
      if pitch_style < 7
        @drawIntensity
        @garnishIntensityRight
      endif
  endif
# if there are two panels to draw
elsif panels = 2
  if selSound = 1
    @topHalf
    if draw_Sound_halfsize = 1
      @halfAgain
    endif
    @drawSound
    @drawLine
  endif
  if specPanel = 1
    if selSound = 1
      @bottomHalf
      if draw_Sound_halfsize = 1
        @increaseByHalf
      endif
    elsif selSound = 0
      @topHalf
    endif
    if selSpectrogram = 1
      @drawSpectrogram
      @drawLine
    endif
    if selFormant = 1
      @drawFormant
      if selSpectrogram = 0
        @garnishFormant
        @drawLine
      endif
    endif
  endif
  if prosPanel = 1
      @bottomHalf
      if selSound = 1 and draw_Sound_halfsize = 1
        @increaseByHalf
      endif
  endif
  if selPitch = 1
     @drawPitch
  endif
  if selIntensity = 1 and selPitch = 0
    @drawIntensity
    @garnishIntensity
  endif
  if selIntensity = 1 and selPitch = 1 and pitch_style < 7
    @drawIntensity
    @garnishIntensityRight
  endif

# if there are three panels to draw
elsif panels = 3
  if draw_Sound_halfsize = 1
    @middleThirdPlus
  else
    @middleThird
  endif
  if selSpectrogram = 1
    @drawSpectrogram
  endif
  if selFormant = 1
    @drawFormant
    if selSpectrogram = 0
      @garnishFormant
    endif
  endif
  @drawLine
  if draw_Sound_halfsize = 1
    @bottomThirdPlus
  else
    @bottomThird
  endif
  if selPitch = 1
     @drawPitch
  endif
  if selIntensity = 1 and selPitch = 0
    @drawIntensity
    @garnishIntensity
  endif
  if selIntensity = 1 and selPitch = 1 and pitch_style < 7
    @drawIntensity
    @garnishIntensityRight
  endif
  if draw_Sound_halfsize = 1
    @topThirdHalf
  else
    @topThird
  endif
  @drawSound
  @drawLine
endif

# draw TextGrid boundaries
if selTextGrid = 1
  selectObject: textGrid
  Select inner viewport: ivpLeft, ivpRight, ivpTop, ivpBottom-topOfTG
  Axes: left_Time_range, right_Time_range, 0, 1
  Dotted line
  if boundaries$ = "yes"
    for i to tiers
      intTier = Is interval tier: i
      if intTier = 1
        labels = Get number of intervals: i
        for x to labels-1
          end = Get end time of interval: i, x
          if end > left_Time_range and end < right_Time_range
            Draw line: end, 0, end, 1
          endif
        endfor
      elsif intTier = 0
        labels = Get number of points: i
        for x to labels
          end = Get time of point: i, x
          if end > left_Time_range and end < right_Time_range
            Draw line: end, 0, end, 1
          endif
        endfor
      endif
    endfor
  endif
  'origLineType$' line
# sets axes the same as Praat when only drawing a TextGrid
newAxisBottom = -1-(tiers*0.5)
Axes: left_Time_range, right_Time_range, newAxisBottom, 1
endif


###############
#
# Finishing off 
#
###############

# select the whole thing
Select inner viewport: oivpLeft, oivpRight, oivpTop, oivpBottom

# garnish outside
@finalGarnish

# restore original selection
@selectOriginal

# saves file to desktop
if save_picture_to_file_on_desktop = 1
  fileName$ = homeDirectory$ + "/Desktop/praat.pdf"
  checkFile = fileReadable (fileName$)
  if checkFile = 0
    Write to PDF file: fileName$
  else
    beginPause: "Warning" 
       comment: "'fileName$' exists.  Picture will not be saved."
    endPause: "OK", 1
  endif
endif