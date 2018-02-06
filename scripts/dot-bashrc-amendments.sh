#!/bin/bash

##----------------------------------------------------------------------
##
##
##  FILE:  .bashrc-amendments, also named dot-bashrc-amendments.sh
##
##
##  LAST TOUCHED:  2017-12-14 THU
##
##
##  DESCRIPTION:  short script to amend Debian and Ubuntu and or
##    Bourne shell run-time config file, normally named '.bashrc'.
##    Adds directory book-marking for up to thirty directories -- or
##    file system paths -- making these accessible by means of
##    three- and four- character aliases of the form 'gdnn' where
##    nn is an integer in the range 1 to 30.
##
##
##  HOW TO USE THIS SCRIPT:
##
##    To enjoy directory bookmark aliases in this file, in a bash
##    command line environment, the user may source this file by
##    hand,
##
##    $ . dot-bashrc-amendments.sh
##
##    or alternately for convenience a given user may amond their
##    .login or .bashrc start-up script to include a line which
##    does the same sourcing of this file.
##
##
##

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

##
##  NOTES ON IMPLEMENTATION:
##
##   (1) When this script is called with no arguments, it reads a run-
##     time config file to determine which group of file-stored,
##     bookmarked paths to read into shell variables and to make readily
##     accessible via path navigation aliases.  If the run-time config
##     is not found the shell creates it and populates it with its
##     identifier '1' for the first group among 1..9 supported groups
##     of path (also referred to as directory) bookmarks.
##
##   (2) When this script is called with a first argument in the range
##     1..9, a single character number representation, the script
##     writes this number to its run-time config file, and uses this
##     number to choose among groups of saved paths written to the
##     given user's dot-bashrc-amendments stored path files.  If not
##     called with a valid bookmarks group id, this script falls back
##     to doing the tasks in (1)
##
##
##
##
##  TO DO:
##
##    [ ]  add to this script function which detects and shows
##         the script's own aliases, and another function(s) to
##         allow user to change aliases, e.g. in event that alias
##         conflicts with a locally installed command,
##
##    [ ]  add to this script the ability to open arbitrary text
##         file containing bookmarked paths, and to show it without
##         replacing present bookmarks,
##
##    [ ]  add to this script a function to show bookmarks it
##         holds and status of whether each given bookmark exists
##         as a valid path on the local file system,
##
##    [ ]  2017-12-02 - add parameters sanity check to routine 'read_bookmarks_file',
##
##    [ ]  2017-12-02 - add settings file to store latest selected group of bookmarks,
##
##
##
##
##
##  TO CONFIRM:
##
##    [ ]  2017-12-02 - make sure that variable 'index' is visible in 
##         the scope of the script which sets the alias 'sp' which
##         saves bookmarked paths,
##
##
##
##  REFERENCES:
##
##    See 'The Linux Documentation Project' at http://tldp.org/
##
##    *  http://tldp.org/LDP/abs/html/testconstructs.html . . . [, [[ ]], (( )) - builtin test,
##         extended test, arithmetic test in bash context
##
##    *  http://tldp.org/LDP/abs/html/testbranch.html     . . . note shell 'shift' parameters operator
##
##    *  http://tldp.org/LDP/abs/html/complexfunct.html   . . . $1 $2 are first parameters to shell functions
##
##    *  http://www.grymoire.com/Unix/Sed.html
##
##    *  https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/
##
##    *  http://www.linuxjournal.com/content/return-values-bash-functions
##
##
##
##  AUTHORS AND MAINTAINERS:
##
##    Ted Havelka, ted@cs.pdx.edu
##
##
##
##----------------------------------------------------------------------



##----------------------------------------------------------------------
##  SECTION - script variables of directory-bookmarker project
##----------------------------------------------------------------------

# SCRIPT VARS BEGIN

GREP=/bin/grep
SED=/bin/sed


SCRIPT_NAME=${0}
# echo "\$SCRIPT_NAME assigned value of \${0} and holds ${SCRIPT_NAME},"
SCRIPT_NAME="dot-bash-amendments.sh"

DIRECTORY_OF_BOOKMARKS_FILES=".bookmarked-paths"

FILENAME_FORM_OF_BOOKMARKED_PATHS="bookmarked-paths-nn.txt"

FILENAME_OF_BOOKMARKS_RUNTIME_CONFIGURATION="bookmarked-paths.rc"

BOOKMARKS_GROUPS_SUPPORTED="1..9"

# Directory Book Marker watermark, for sane $PATH amendments:
DBM_WATERMARK="${HOME}/path-amended-by-directory-bookmarker"

# . . .
bookmarks_group_id=1

# Shell variable used in 'sp' alias to save bookmarked paths:
index=0


## 2017-12-02 - How are these variables used? - TMH
bash_settings_file="${HOME}/.bash_settings_local"


# SCRIPT VARS END




##----------------------------------------------------------------------
##  SECTION - script functions
##----------------------------------------------------------------------

function show_aliases_in_this_script()
{
## 2017-12-02 NEED - Contributor Ted noting that following command will
##  show all script lines, including comments and commented out
##  commands (which are also comments), which this function's name
##  does not indicate.  NEED to fix this or rename this function . . .

    $(GREP) -n alias $0
}



function set_aliases()
{
##----------------------------------------------------------------------
##  PURPOSE: . . .
##----------------------------------------------------------------------

#    echo "setting some shell safety and shortcut aliases . . ."


## Some important shell safe-guarding aliases for Unix and Linux systems:

    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'

# list files in long format starting from a cleared screen:
    alias lss='clear; ls -lF'

# list directories only in long format:
    alias dls='ls -l | grep "^d"'



# run custom Remote UPtime script:
    alias rup='${HOME}/bin/rup'

# . . .
    alias cvs='cvs -d ${HOME}/cvs -e /usr/bin/vi'


# Shell shortcuts to cd to local oft used directories:

    alias archive='cd ${HOME}/archive; echo "Now at `pwd`" '
    alias bin='cd ${HOME}/bin; echo "Now at `pwd`" '
    alias notes='cd ${HOME}/notes; echo "Now at `pwd`" '


# 2012-01-25

    alias xterm='xterm -bg black -fg white -geometry 108x36'
    alias x='xterm -bg black -fg white -geometry 115x36 &'


# NOTE 2017-12-02 - xlock command generally not available on last
#  three years' Debian and Ubuntu software package mirrors.  Related
#  command 'xscreensaver-command -lock' is installable . . .

    alias xlock='/usr/bin/xlock -mode scooter -count 100'


    alias restore-path-var='. ${HOME}/dot-bashrc-amendments.sh restore-path-variable'


} # end function set_aliases()




function set_aliases_for_bookmarking()
{

#    echo "setting aliases for bookmarking of paths . . ."

#---------------------------------------------------------------------
# STEP:  create aliases for saving paths and returning to paths
#---------------------------------------------------------------------

# setting of bookmarks 1 through 10:

    alias sd1='export D1=`pwd`; echo "Set variable D1 to `pwd`" '
    alias sd2='export D2=`pwd`; echo "Set variable D2 to `pwd`" '
    alias sd3='export D3=`pwd`; echo "Set variable D3 to `pwd`" '
    alias sd4='export D4=`pwd`; echo "Set variable D4 to `pwd`" '
    alias sd5='export D5=`pwd`; echo "Set variable D5 to `pwd`" '

    alias sd6='export D6=`pwd`; echo "Set variable D6 to `pwd`" '
    alias sd7='export D7=`pwd`; echo "Set variable D7 to `pwd`" '
    alias sd8='export D8=`pwd`; echo "Set variable D8 to `pwd`" '
    alias sd9='export D9=`pwd`; echo "Set variable D9 to `pwd`" '
    alias sd10='export D10=`pwd`; echo "Set variable D10 to `pwd`" '

# setting of bookmarks 11 through 20:

    alias sd11='export D11=`pwd`; echo "Set variable D11 to `pwd`" '
    alias sd12='export D12=`pwd`; echo "Set variable D12 to `pwd`" '
    alias sd13='export D13=`pwd`; echo "Set variable D13 to `pwd`" '
    alias sd14='export D14=`pwd`; echo "Set variable D14 to `pwd`" '
    alias sd15='export D15=`pwd`; echo "Set variable D15 to `pwd`" '

    alias sd16='export D16=`pwd`; echo "Set variable D16 to `pwd`" '
    alias sd17='export D17=`pwd`; echo "Set variable D17 to `pwd`" '
    alias sd18='export D18=`pwd`; echo "Set variable D18 to `pwd`" '
    alias sd19='export D19=`pwd`; echo "Set variable D19 to `pwd`" '
    alias sd20='export D20=`pwd`; echo "Set variable D20 to `pwd`" '

# setting of bookmarks 21 through 30:

    alias sd21='export D21=`pwd`; echo "Set variable D21 to `pwd`" '
    alias sd22='export D22=`pwd`; echo "Set variable D22 to `pwd`" '
    alias sd23='export D23=`pwd`; echo "Set variable D23 to `pwd`" '
    alias sd24='export D24=`pwd`; echo "Set variable D24 to `pwd`" '
    alias sd25='export D25=`pwd`; echo "Set variable D25 to `pwd`" '

    alias sd26='export D26=`pwd`; echo "Set variable D26 to `pwd`" '
    alias sd27='export D27=`pwd`; echo "Set variable D27 to `pwd`" '
    alias sd28='export D28=`pwd`; echo "Set variable D28 to `pwd`" '
    alias sd29='export D29=`pwd`; echo "Set variable D29 to `pwd`" '
    alias sd30='export D30=`pwd`; echo "Set variable D30 to `pwd`" '

#    echo "- TEST - setting alias SD31 . . ."
    alias sd31='echo "Doh, thirty one bookmarks not supported!"'


# navigation to bookmarked directories 1 through 10:

    alias gd1='cd $D1; echo "Now at $D1" '
    alias gd2='cd $D2; echo "Now at $D2" '
    alias gd3='cd $D3; echo "Now at $D3" '
    alias gd4='cd $D4; echo "Now at $D4" '
    alias gd5='cd $D5; echo "Now at $D5" '

    alias gd6='cd $D6; echo "Now at $D6" '
    alias gd7='cd $D7; echo "Now at $D7" '
    alias gd8='cd $D8; echo "Now at $D8" '
    alias gd9='cd $D9; echo "Now at $D9" '
    alias gd10='cd $D10; echo "Now at $D10" '

# navigation to bookmarked directories 11 through 20:

    alias gd11='cd $D11; echo "Now at $D11" '
    alias gd12='cd $D12; echo "Now at $D12" '
    alias gd13='cd $D13; echo "Now at $D13" '
    alias gd14='cd $D14; echo "Now at $D14" '
    alias gd15='cd $D15; echo "Now at $D15" '

    alias gd16='cd $D16; echo "Now at $D16" '
    alias gd17='cd $D17; echo "Now at $D17" '
    alias gd18='cd $D18; echo "Now at $D18" '
    alias gd19='cd $D19; echo "Now at $D19" '
    alias gd20='cd $D20; echo "Now at $D20" '

# navigation to bookmarked directories 21 through 30:

    alias gd21='cd $D21; echo "Now at $D21" '
    alias gd22='cd $D22; echo "Now at $D22" '
    alias gd23='cd $D23; echo "Now at $D23" '
    alias gd24='cd $D24; echo "Now at $D24" '
    alias gd25='cd $D25; echo "Now at $D25" '

    alias gd26='cd $D26; echo "Now at $D26" '
    alias gd27='cd $D27; echo "Now at $D27" '
    alias gd28='cd $D28; echo "Now at $D28" '
    alias gd29='cd $D29; echo "Now at $D29" '
    alias gd30='cd $D30; echo "Now at $D30" '






## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##  Banner message at end of alias 's' . . .
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

alias s='\
echo
echo "Bookmarked paths in bookmarks group ${bookmarks_group_id} are:"
echo
\
echo "variable D1 points to $D1";\
 echo variable D2 points to $D2; echo variable D3 points to $D3; echo variable D4 points to $D4; echo variable D5 points to $D5; echo variable D6 points to $D6; echo variable D7 points to $D7; echo variable D8 points to $D8; echo variable D9 points to $D9; echo variable D10 points to $D10;\
\
echo " - - - - -";\
\
echo variable D11 points to $D11; echo variable D12 points to $D12; echo variable D13 points to $D13; echo variable D14 points to $D14; echo variable D15 points to $D15; echo variable D16 points to $D16; echo variable D17 points to $D17; echo variable D18 points to $D18; echo variable D19 points to $D19; echo variable D20 points to $D20;\
\
echo " - - - - -";\
\
echo "variable D21 points to $D21";\
echo "variable D22 points to $D22";\
echo "variable D23 points to $D23";\
echo "variable D24 points to $D24";\
echo "variable D25 points to $D25";\
\
echo "variable D26 points to $D26";\
echo "variable D27 points to $D27";\
echo "variable D28 points to $D28";\
echo "variable D29 points to $D29";\
echo "variable D30 points to $D30";\
\
echo; \
echo EDITOR is set to: $EDITOR;\
echo "see file dot-bashrc-amendments.sh, typically in home directory of present user,";\
echo "for implementation of directory bookmarks and D1..D30 variables - TMH";\
echo "this shell script written by Ted Havelka and licensed under GNU Public License, 2005 - 2017";\
\
echo'

##------------------------------------------------------------------------------





alias sp='bookmarked_path[0]="zztop"; 
   bookmarked_path[1]=$D1;    bookmarked_path[2]=$D2;    bookmarked_path[3]=$D3;    bookmarked_path[4]=$D4;    bookmarked_path[5]=$D5; 
   bookmarked_path[6]=$D6;    bookmarked_path[7]=$D7;    bookmarked_path[8]=$D8;    bookmarked_path[9]=$D9;   bookmarked_path[10]=$D10; 

  bookmarked_path[11]=$D11;  bookmarked_path[12]=$D12;  bookmarked_path[13]=$D13;  bookmarked_path[14]=$D14;  bookmarked_path[15]=$D15; 
  bookmarked_path[16]=$D16;  bookmarked_path[17]=$D17;  bookmarked_path[18]=$D18;  bookmarked_path[19]=$D19;  bookmarked_path[20]=$D20; 

  bookmarked_path[21]=$D21;  bookmarked_path[22]=$D22;  bookmarked_path[23]=$D23;  bookmarked_path[24]=$D24;  bookmarked_path[25]=$D25; 
  bookmarked_path[26]=$D26;  bookmarked_path[27]=$D27;  bookmarked_path[28]=$D28;  bookmarked_path[29]=$D29;  bookmarked_path[30]=$D30; 

## 2017-12-14 THU:
  echo "about to save bookmarked paths using old script code in alias," 
  echo "in this code \$filename holds '$filename'," 
  echo "to local file $filename saving bookmarked directories:";
  echo -n > $filename; 
  for index in 0  1 2 3 4 5 6 7 8 9 10  11 12 13 14 15 16 17 18 19 20  21 22 23 24 25 26 27 28 29 30; do
      echo "saving bookmarked path $index = ${bookmarked_path[$index]}"; 
      echo ${bookmarked_path[$index]} >> $filename; 
  done'



# alias clearpaths='\
# echo "Clearing bookmarked paths in present shell . . ." \
# echo "Note:  bookmarked paths in bookmarks group ${bookmarks_group_id} still stored in ${filename}" \
# export D1=""; export D2=""; export D3=""; export D4=""; export D5=""; \
# export D6=""; export D7=""; export D8=""; export D9=""; export D10=""; \
# \
# export D11=""; export D12=""; export D13=""; export D14=""; export D15=""; \
# export D16=""; export D17=""; export D18=""; export D19=""; export D20=""; \
# \
# export D21=""; export D22=""; export D23=""; export D24=""; export D25=""; \
# export D26=""; export D27=""; export D28=""; export D29=""; export D30="";'


## 2017-12-14 - unexpected new behavior observed when backslash characters
##  appear in alias defining statement above, removing those:

alias clearpaths='
echo "Clearing bookmarked paths in present shell . . ."
echo "Note:  bookmarked paths in bookmarks group ${bookmarks_group_id} still stored in ${filename}"
echo "use \`lp${bookmarks_group_id}\` to reload those bookmarked paths."
export D1=""; export D2=""; export D3=""; export D4=""; export D5=""; \
export D6=""; export D7=""; export D8=""; export D9=""; export D10=""; \
\
export D11=""; export D12=""; export D13=""; export D14=""; export D15=""; \
export D16=""; export D17=""; export D18=""; export D19=""; export D20=""; \
\
export D21=""; export D22=""; export D23=""; export D24=""; export D25=""; \
export D26=""; export D27=""; export D28=""; export D29=""; export D30="";'



# 2017-12-02 - NEED TO ADDRESS INTENT AND ACTION OF load-paths:
# This alias likely doesn't work as intended, to load one set
# of bookmarked paths over others . . .    - TMH

alias load-paths=' \
export D1=${bookmarked_path[1]}; \
export D2=${bookmarked_path[2]}; \
export D3=${bookmarked_path[3]}; \
export D4=${bookmarked_path[4]}; \
export D5=${bookmarked_path[5]}; \
export D6=${bookmarked_path[6]}; \
export D7=${bookmarked_path[7]}; \
export D8=${bookmarked_path[8]}; \
export D9=${bookmarked_path[9]}; \
export D10=${bookmarked_path[10]}; \
\
export D11=${bookmarked_path[11]}; \
export D12=${bookmarked_path[12]}; \
export D13=${bookmarked_path[13]}; \
export D14=${bookmarked_path[14]}; \
export D15=${bookmarked_path[15]}; \
export D16=${bookmarked_path[16]}; \
export D17=${bookmarked_path[17]}; \
export D18=${bookmarked_path[18]}; \
export D19=${bookmarked_path[19]}; \
export D20=${bookmarked_path[20]}; \
\
export D21=${bookmarked_path[21]}; \
export D22=${bookmarked_path[22]}; \
export D23=${bookmarked_path[23]}; \
export D24=${bookmarked_path[24]}; \
export D25=${bookmarked_path[25]}; \
export D26=${bookmarked_path[26]}; \
export D27=${bookmarked_path[27]}; \
export D28=${bookmarked_path[28]}; \
export D29=${bookmarked_path[29]}; \
export D30=${bookmarked_path[30]}; \
echo "Loaded user-saved paths:"; s'


# Aliases to load different groups of bookmarked paths:

    alias lp1='. ${HOME}/dot-bashrc-amendments.sh 1'
    alias lp2='. ${HOME}/dot-bashrc-amendments.sh 2'
    alias lp3='. ${HOME}/dot-bashrc-amendments.sh 3'
    alias lp4='. ${HOME}/dot-bashrc-amendments.sh 4'
    alias lp5='. ${HOME}/dot-bashrc-amendments.sh 5'


# 2017-12-14 - Alias 'show non-empty bookmarks' added by Ted:

    alias sne='
echo
echo "Showing non-empty bookmarks in bookmarks group ${bookmarks_group_id}:"
echo
 bookmarked_path[1]=$D1;    bookmarked_path[2]=$D2;    bookmarked_path[3]=$D3;    bookmarked_path[4]=$D4;    bookmarked_path[5]=$D5; 
 bookmarked_path[6]=$D6;    bookmarked_path[7]=$D7;    bookmarked_path[8]=$D8;    bookmarked_path[9]=$D9;   bookmarked_path[10]=$D10; 

bookmarked_path[11]=$D11;  bookmarked_path[12]=$D12;  bookmarked_path[13]=$D13;  bookmarked_path[14]=$D14;  bookmarked_path[15]=$D15; 
bookmarked_path[16]=$D16;  bookmarked_path[17]=$D17;  bookmarked_path[18]=$D18;  bookmarked_path[19]=$D19;  bookmarked_path[20]=$D20; 

bookmarked_path[21]=$D21;  bookmarked_path[22]=$D22;  bookmarked_path[23]=$D23;  bookmarked_path[24]=$D24;  bookmarked_path[25]=$D25; 
bookmarked_path[26]=$D26;  bookmarked_path[27]=$D27;  bookmarked_path[28]=$D28;  bookmarked_path[29]=$D29;  bookmarked_path[30]=$D30; 

for index in 1 2 3 4 5 6 7 8 9 10  11 12 13 14 15 16 17 18 19 20  21 22 23 24 25 26 27 28 29 30; do

    if [ -z ${bookmarked_path[$index]} ]; then
        echo "bookmarked_path[$index] not set," >> /dev/null
    else
        echo "\$D${index} set to ${bookmarked_path[$index]},"
    fi
done
echo
echo "Note:  dot-bash-amendments script supports thirty (30) bookmarked paths per bookmarks group."
echo'

} # end function set_aliases_for_bookmarking()




function read_bookmarks_runtime_config()
{

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## VARS BEGIN

    local rname="read_bookmarks_runtime_config"

    local line="DEFAULT_LINE_TO_BE_READ_FROM_FILE"

    local bookmarks_group_id=""

## VARS END
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    


#    echo "* * * SCRIPT FUNCTION ${rname}() IMPLEMENTATION UNDERWAY * * *"

    filename=${HOME}/${DIRECTORY_OF_BOOKMARKS_FILES}/${FILENAME_OF_BOOKMARKS_RUNTIME_CONFIGURATION}

    if [ -e ${filename} ]; then
        # read bookmarked paths runtime config file . . .
#        echo "${rname}:  reading directory bookmarks runtime configuration file ${filename},"
#        cat ${filename}

        read -r line < ${filename}
#        echo "line 1 holds:  ${line}"

    else
        touch ${filename}
        if [ -e ${filename} ]; then
            echo "1" >> ${filename}
        else
            echo "${SCRIPT_NAME}:  - WARNING - unable to open and unable to create runtime config file!"
            echo "${SCRIPT_NAME}:  - will start with bookmarks group set to 1,"
            echo "${SCRIPT_NAME}:  - presently bookmarks groups 1 through 9 supported."
        fi
    fi

    echo ${line}
## 2017-12-14 - Commented echo statement and variable for later time when
##  this script able to parse several settings from rc file:
#    echo ${bookmarks_group_id}

} # end function read_bookmarks_runtime_config()




function write_bookmarks_runtime_config()
{
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##  2017-12-14 - Script contributor Ted noting that this function to
##   write the bookmarks run-time config file is nearly identical to
##   the function to read this same file.  Wondering if there's an
##   elegant way to combine the two functions?  - TMH
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    echo "* * * Script function write_bookmarks_runtime_config() implementation underway * * *"
    echo "called with bookmarks group identifier '${1}',"

    filename=${HOME}/${DIRECTORY_OF_BOOKMARKS_FILES}/${FILENAME_OF_BOOKMARKS_RUNTIME_CONFIGURATION}

    if [ -e ${filename} ]; then
        # write one value bookmarked paths runtime config file, overwriting all data in this file:
        echo "${SCRIPT_NAME}:  writing directory bookmarks runtime configuration file . . ."
        echo ${1} > ${filename}
    else
        touch ${filename}
        if [ -e ${filename} ]; then
            echo ${1} > ${filename}
        else
            echo "${SCRIPT_NAME}:  - WARNING - unable to open and unable to create runtime config file!"
            echo "${SCRIPT_NAME}:  - will start with bookmarks group set to 1,"
            echo "${SCRIPT_NAME}:  - presently bookmarks groups 1 through 9 supported."
        fi
    fi
}





function read_bookmarks_file()
{

#    echo "*** Routine 'read_bookmarks_file' development in progress, ***"
#    echo "first two arguments from caller are '$1' and '$2',"
#    echo "variable \${SED} holds '${SED}',"

    local bookmarked_paths_group=${2}

REGEX="[1-9]"
#    if [[ ${bookmarked_paths_group} =~ [1-5] ]] ; then
    if [[ ${bookmarked_paths_group} =~ ${REGEX} ]] ; then
        echo "caller requests valid bookmarks file identified by '${2}', which is in the range ${BOOKMARKS_GROUPS_SUPPORTED}"
    else
        echo "- NOTE - caller requests unsupported or unknown bookmarks file identified by '${2}',"
        echo "- NOTE - defaulting to read bookmarked directories in bookmarks group 1,"
        bookmarked_paths_group=1
    fi

##    bookmarks_filename=$(echo ${FILENAME_FORM_OF_BOOKMARKED_PATHS} | ${SED} s/nn/0${2}/)
    bookmarks_filename=$(echo ${FILENAME_FORM_OF_BOOKMARKED_PATHS} | ${SED} s/nn/0${bookmarked_paths_group}/)

    echo "will read bookmarks from file named ${bookmarks_filename},"

## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##  NOTE - had trouble getting these export statements to fly . . .
##
##   Ahh finally makes sense now 2017 DEC, these export statements
##   don't express explicit variable names.  That is, bash must see
##   a shell script declared array element as something other than a
##   valid variable name:                                         - TMH
## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# export ${bookmarked_path[0]}
# export ${bookmarked_path[1]}
# export ${bookmarked_path[2]}
# export ${bookmarked_path[3]}
# export ${bookmarked_path[4]}
# export ${bookmarked_path[5]}



##----------------------------------------------------------------------
##  STEP:  retrieve saved paths from previous user session
##----------------------------------------------------------------------

# filename="${HOME}/.bash_paths_saved"
# filename="${HOME}/bookmarked-paths.txt"  . . . commmented 2017-12-02 SAT
filename=${HOME}/${DIRECTORY_OF_BOOKMARKS_FILES}/${bookmarks_filename}

## 2017-02-09 THU - To be added, support for storing and perusing multiple directory bookmarks files:
filename__list_of_bookmark_files="${HOME}/bookmarked-path-files.txt"



# REFERENCE:  http://tldp.org/LDP/abs/html/arrays.html

declare -a bookmarked_path=()



if [ -e ${filename} ]; then
    bookmarked_path=( $(cat "$filename") )  #  Stores contents of this script
                                     #+ ($bash_settings_local) in an array.
else
#    echo "$O:  no local bash settings file named ${bash_settings_file} found," > /dev/null
    echo "${SCRIPT_NAME}:  - WARNING - direcory bookmarks file named ${filename} not found!"
    echo "${SCRIPT_NAME}:  - not able to read in bookmarked directories from this file,"
    echo "${SCRIPT_NAME}:  - but creating to hold paths going forward . . ."
    touch ${filename}
    return
fi


    if [ ]; then
        echo ""
        echo "- DIAG START -"
        echo "after reading bookmarks file,"
        echo "\${bookmarked_path[1]} holds '${bookmarked_path[1]}'"
        echo "\${bookmarked_path[2]} holds '${bookmarked_path[2]}'"
        echo "\${bookmarked_path[3]} holds '${bookmarked_path[3]}'"
        echo "- DIAG END -"
        echo ""
    fi


# 2006-11-27
# Prior to storing user-saved paths in a local file, path
# variables were assigned zero-length strings and exported like this:
#
# export D1=""
#
# Now these variables are exported the same way but assigned
# differently . . .

# echo "reading saved paths from file, skipping first place-holder token '${bookmarked_path[0]}' . . ."

    export D1=${bookmarked_path[1]}
    export D2=${bookmarked_path[2]}
    export D3=${bookmarked_path[3]}
    export D4=${bookmarked_path[4]}
    export D5=${bookmarked_path[5]}

    export D6=${bookmarked_path[6]}
    export D7=${bookmarked_path[7]}
    export D8=${bookmarked_path[8]}
    export D9=${bookmarked_path[9]}
    export D10=${bookmarked_path[10]}

    export D11=${bookmarked_path[11]}
    export D12=${bookmarked_path[12]}
    export D13=${bookmarked_path[13]}
    export D14=${bookmarked_path[14]}
    export D15=${bookmarked_path[15]}

    export D16=${bookmarked_path[16]}
    export D17=${bookmarked_path[17]}
    export D18=${bookmarked_path[18]}
    export D19=${bookmarked_path[19]}
    export D20=${bookmarked_path[20]}

    export D21=${bookmarked_path[21]}
    export D22=${bookmarked_path[22]}
    export D23=${bookmarked_path[23]}
    export D24=${bookmarked_path[24]}
    export D25=${bookmarked_path[25]}

    export D26=${bookmarked_path[26]}
    export D27=${bookmarked_path[27]}
    export D28=${bookmarked_path[28]}
    export D29=${bookmarked_path[29]}
    export D30=${bookmarked_path[30]}


    if [ ]; then
        echo ""
        echo "- DIAG START -"
        echo "after exporting \$D1..\$D30,"
        echo "\$D1 holds '$D1',"
        echo "\$D2 holds '$D2',"
        echo "\$D3 holds '$D3',"
        echo "- DIAG END -"
        echo ""
    fi


} # end function read_bookmarks_file()




function clear_paths_function()
{

#    echo "clear_paths_function:  clearing bookmarked paths in current shell, setting \$D1..\$D30 to '',"

    export D1=""; export D2=""; export D3=""; export D4=""; export D5="";
    export D6=""; export D7=""; export D8=""; export D9=""; export D10="";

    export D11=""; export D12=""; export D13=""; export D14=""; export D15="";
    export D16=""; export D17=""; export D18=""; export D19=""; export D20="";

    export D21=""; export D22=""; export D23=""; export D24=""; export D25="";
    export D26=""; export D27=""; export D28=""; export D29=""; export D30="";

}




function amend_path_variable()
{
##----------------------------------------------------------------------
##  PURPOSE:  amend user's $PATH environment variable
##
##  NEED:  to add logic so that for a given shell session, when this
##   script called a second or successive time it does not amend the
##   $PATH variable with duplicate paths.  Need a test . . .   - TMH
##
##----------------------------------------------------------------------

    string=`echo $PATH | grep $DBM_WATERMARK`

    if [ -z "$string" ]
    then
        path_as_found=${PATH}

# Amending the default path variable:

#        PATH="/usr/bin:${PATH}"
        PATH="${PATH}":/sbin
        PATH="${PATH}":/usr/sbin
        PATH="${PATH}":/opt/bin
        PATH="${PATH}":/opt/cross/bin
        PATH="${PATH}":/opt/cross/x-tools/arm-unknown-linux-gnueabi/bin
#        PATH="${PATH}":.
        PATH="${PATH}":${HOME}/bin
        PATH="${PATH}":/usr/local/mysql/bin
        PATH="${PATH}":/usr/lib/xscreensaver
        PATH="${PATH}":/etc/init.d

# 2014-01-24 . . .
        PATH="${PATH}":/var/opt/sam-ba_cdc_cdc_linux

# 2017-12-04 . . .
        PATH="${PATH}":~/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin

# 2018-01-19 - add a pattern to the path to avoid multple path variable
#  amendments per shell session:
        PATH="${PATH}:$DBM_WATERMARK"

    else
        echo "\$PATH variable already amended, directory book-marker leaving untouched."
    fi

}



function restore_path_variable_to_as_found()
{
    PATH=$path_as_found
}





##----------------------------------------------------------------------
##
##  SECTION - main-line code of dot-bash-amendments.sh
##
##----------------------------------------------------------------------

echo "starting,"

## Following test fails when script passed an argument, should succeed . . .
#if [[ "$ARGC" -eq "1" ]]; then
#    echo "called with first argument set to '$1',"
#fi

## Following test succeeds:
if [[ "$#" -eq "1" ]]; then
    echo "called with first argument set to '$1',"
#    echo "calling 'read directory bookmarks file' with no arguments . . ."
#    read_bookmarks_file
fi



## Note:  single brackets in the following test work, double brackets
##  seem to evaulate differently, may be because we're using a shell
##  file test . . .

bookmarks_dir="${HOME}/${DIRECTORY_OF_BOOKMARKS_FILES}"

# echo "- DEV - constructed bookmarked paths directory which holds '$bookmarks_dir',"
## 2017-12-03 - DISCOVERY:  hey why does bash 'file exists' test return true when 
## +  the argument to the file test is a zero-length string?  Or undefined variable?
## +  Does Mendel Cooper's guide explain this behavior?  There was a type 
## +  just below with 'bookmarks_dir' spelled 'booksmarks_dir' . . .  - TMH

if [ -e ${bookmarks_dir} ]; then
#    echo "found directory '${bookmarks_dir}' for bookmarked path files, not creating this directory."
    echo "found directory '${bookmarks_dir}' for bookmarked path files, not creating this directory." > /dev/null
else
#    echo "creating directory ${bookmarks_dir} . . ."
    mkdir -pv ${bookmarks_dir}
fi



##----------------------------------------------------------------------
##  STEP:  set shell aliases . . . moved to two functions of this script
##----------------------------------------------------------------------

    set_aliases

    set_aliases_for_bookmarking

#    echo "- DIAG BEGIN - calling builtin shell command 'alias' to check aliases just set:"
#    alias
#    echo "- DIAG END -"



##----------------------------------------------------------------------
##  STEP - read file holding bookmarked paths
##----------------------------------------------------------------------

#    echo "- DIAG BEGIN - calling function (not alias) to clear any directory bookmarks . . ."
    clear_paths_function
#    echo "- DIAG END - \$D1 holds '$D1'"

##  *  https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash

     re='^[0-9]+$'
     if [[ $1 =~ $re ]]; then
        if [ "$#" -gt 0 ]; then
            bookmarks_group_id=${1}
        else
            bookmarks_group_id=1
        fi
     fi



##----------------------------------------------------------------------
##  STEP - check for valid bookmarks group identifier, should be
##  an integer value between 1 and 9 for now, 2017 December:
##----------------------------------------------------------------------

bookmarked_paths_group_in_script_main_line=${1}

if [[ ${bookmarked_paths_group_in_script_main_line} =~ [1-9] ]] ; then
    echo "script called with bookmarks group number ${bookmarked_paths_group_in_script_main_line}, in range ${BOOKMARKS_GROUPS_SUPPORTED}"
    echo "which we support as of 2017 December."
    write_bookmarks_runtime_config ${bookmarked_paths_group_in_script_main_line}
else
    if [ -z ${bookmarked_paths_group_in_script_main_line} ]; then
#        echo "setting bookmarks group to default value of 1, first group of bookmarks among ${BOOKMARKS_GROUPS_SUPPORTED}"
#        bookmarked_paths_group_in_script_main_line=1

        echo "script called without bookmarked paths group specified,"
        echo "looking for last-used bookmarks group in dot-bash-amendments run-time config file . . ."
        bookmarks_group_id=$(read_bookmarks_runtime_config)
        echo "- DEV - from rc file read bookmarks group id '${bookmarks_group_id}',"
    else
        echo "- NOTE - script called with unsupported bookmarks group id,"
        echo "- NOTE - id we got is '${bookmarked_paths_group_in_script_main_line}',"
        echo "- NOTE - setting bookmarks group to default value of 1, first group of bookmarks among ${BOOKMARKS_GROUPS_SUPPORTED}"
        bookmarked_paths_group_in_script_main_line=1
    fi
fi


# echo "calling bash amendments function to read run-time config file . . ."
# read_bookmarks_runtime_config

echo "calling 'read directory bookmarks file' with arguments '$0 ${bookmarks_group_id}' . . ."
read_bookmarks_file $0 ${bookmarks_group_id}




## See http://tldp.org/LDP/abs/html/testconstructs.html, example script 7-1:

if [ ]; then
    echo ""
    echo "- DIAG START in main-line code of script -"
    echo "back from call to read_bookmarks_file() which exports \$D1..\$D30,"
    echo "\$D1 holds '$D1',"
    echo "\$D2 holds '$D2',"
    echo "\$D3 holds '$D3',"
    echo "- DIAG END in main-line code of script -"
    echo ""
fi




##----------------------------------------------------------------------
##  STEP - amend environment variables
##----------------------------------------------------------------------

#
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##  NOTE - path environment variable amendments, mostly for
##   work on Debian and Ubuntu Linux based systems
##
##  NOTE - when $PATH variable includes present working directory, e.g.
##   "." then buildroot 2.x complains and bails during project
##   compilation.  For smooth buildroot project builds, keep the 
##   current working directory commented out.  Safer to run programs
##   in cwd using ./[program_name] syntax anyway . . .  - TMH
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#

# Amending the default path variable:

    if [ "$1" == "restore-path-variable" ]; then 
echo "- dbm - RESTORING PATH VARIABLE . . ."
        restore_path_variable_to_as_found
    else
        amend_path_variable
    fi


# Concurrent Versions System (CVS) variables:

    CVSROOT="/home/fulano/cvs"
    CVS_RSH=""
#    export EDITOR=/usr/bin/vim . . . commented out 2012-01-25 - TMH
    export EDITOR=/usr/bin/vi
    HISTSIZE=1000
    HISTFILESIZE=1000

# Variables as shortcuts:

    archive=${HOME}/archive

# Enable tsocks transparent proxy service by setting this environment
# variable:

## Note - needed back in 2004, 2005 for to enable proxy server
##  settings . . .

#    export LD_PRELOAD=/lib/libtsocks.so.1.8
#    export LD_PRELOAD=/usr/lib/libtsocks.so.1.8



##----------------------------------------------------------------------
##  2014-02-19 - added by Ted . . .
##
##  STEP - cross compile variables to export
##
##  reference http://www.x.org/wiki/CrossCompilingXorg/
##----------------------------------------------------------------------

# export CROSS_COMPILE=arm-none-linux-gnueabi-
export CROSS_COMPILE=arm-unknown-linux-gnueabi-

export SESSION_MANAGER=lightdm



echo "done."



# EOF ( end of file )
