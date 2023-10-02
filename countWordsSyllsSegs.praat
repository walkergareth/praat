# countWordsSyllsSegs.praat. A Praat script for estimating the number of words, 
# syllables, and segments from text input provided in a dialog box. 

# Praat uses espeak-ng (https://github.com/espeak-ng/espeak-ng) to
# create the transcription. Defaults to English (Great Britain).

# Diphthongs, long vowels and affricates are treated as single segments. The 
# number of intervals containing one or more vowel symbol(s) is taken to be
# the number of syllables.  

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

form: "Enter your text..."
  text: 5, "Text:", "this is some text"
  choice: "Output_format", 1
    option: "column"
    option: "row"
    option: "column (no units)"
    option: "row (no units)"
  comment: "Choose language"
    optionmenu: "Language", 1
      option: "English (Great Britain)"
      option: "English (America)"
  boolean: "clear Info window", 1
endform

if language = 1
  lang$ = "English (Great Britain)"
elsif language = 2
  lang$ = "English (America)"
endif

#empty the Info window
if clear_Info_window = 1
  writeInfo: ""
endif

# all IPA vowel and consonant symbols as they appear on the IPA chart,
# plus some affricate symbols available in the Praat menus, for use in
# regexes later
vowels$ = "(i|y|ɨ|ʉ|ɯ|u|ɪ|ʏ|ʊ|e|ø|ɘ|ɵ|ɤ|o|ə|ɛ|œ|ɜ|ɞ|ʌ|ɔ|æ|ɐ|a|ɶ|ɑ|ɒ|ɚ|a˞)"
consonants$ = "(p|b|t|d|ʈ|ɖ|c|ɟ|k|ɡ|q|ɢ|ʔ|m|ɱ|n|ɳ|ɲ|ŋ|ɴ|ʙ|r|ʀ|ⱱ|ɾ|ɽ|ɸ|β|f|v|θ|ð|s|z|ʃ|ʒ|ʂ|ʐ|ç|ʝ|x|ɣ|χ|ʁ|ħ|ʕ|h|ɦ|ɬ|ɮ|ʋ|ɹ|ɻ|j|ɰ|l|ɭ|ʎ|ʟ|ʘ|ǀ|ǃ|ǂ|ǁ|ɓ|ɗ|ʄ|ɠ|ʛ|pʼ|tʼ|kʼ|sʼ|ʍ|w|ɥ|ʜ|ʢ|ʡ|ɕ|ʑ|ɺ|ɧ|ʧ|ʤ|ʦ|ʣ|ʨ|ʥ)"

# create the objects
spSyn = Create SpeechSynthesizer: lang$, "Female1"
To Sound: text$, "yes"
sound = selected ("Sound")
textGrid = selected ("TextGrid")
selectObject: textGrid

trans$ = ""
ints = Get number of intervals: 4
for i to ints
  lab$ = Get label of interval: 4, i

  # if there are two symbols in an interval, and the first is a vowel
  # and the second is a consonant, split them up with an underscore;
  # this is designed to avoid syllabic consonants being treated as a
  # single segment
  if length(lab$) = 2 and index_regex (lab$, vowels$) = 1 and index_regex (lab$, consonants$) = 2
    lab$ = left$ (lab$, 1) + "_" + right$ (lab$, 1)
  endif

  trans$ = trans$ + "_" + lab$
endfor

# count words based on number of spaces in the text$

# remove any multiple spaces
multi_spaces = rindex (text$, "  ")
repeat
  text$ = replace$ (text$, "  ", " ", 0)
  multi_spaces = rindex (text$, "  ")
until multi_spaces = 0 
# remove any initial space
if startsWith (text$, " ") = 1
  text$ = replace$ (text$, " ", "", 1)
endif
# remove any final space
if endsWith (text$, " ") = 1
  text_length = length (text$)
  text$ = left$ (text$, text_length-1)
endif


text_length = length (text$)
spaces = 0
for s to text_length
  char$ = mid$ (text$, s, 1)
  if char$ = " "
    spaces = spaces + 1
  endif
endfor
wordsT = spaces + 1


# make a readable version
transWord$ = replace_regex$ (trans$, "__", " ", 0) ; replace double underscore with space
transWord$ = replace_regex$ (transWord$, "_", "", 0) ; remove underscore 
transWord$ = replace_regex$ (transWord$, "^ ", "", 0) ; remove initial space

# make a version with underscores to identify segment boundaries
trans$ = replace_regex$ (trans$, "__", "_", 0) ; replace double underscore with underscore
trans$ = replace_regex$ (trans$, "^_", "", 0) ; remove initial underscore

words = Count intervals where: 3, "matches (regex)", "."
segs = Count intervals where: 4, "matches (regex)", "."
sylls = Count intervals where: 4, "matches (regex)", vowels$

# variables for different ouput formats
br$ = newline$
if output_format = 2 or output_format = 4
  br$ = ","
endif
wUnitsT$ = " words (text_string)"
wUnits$ = " words (espeak-ng)"
syUnits$ = " syllables"
sgUnits$ = " segments"
if output_format = 3 or output_format = 4
  wUnitsT$ = ""
  wUnits$ = ""
  syUnits$ = ""
  sgUnits$ = ""
endif

# prints the information
appendInfoLine: text$, br$,
  ...transWord$, br$, 
  ...trans$, br$, 
  ...wordsT, wUnitsT$, br$, 
  ...words, wUnits$, br$, 
  ...sylls, syUnits$, br$, 
  ...segs, sgUnits$

# cleans up
plusObject: sound
plusObject: spSyn
Remove
