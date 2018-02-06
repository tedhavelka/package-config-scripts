#!/bin/bash

#---------------------------------------------------------------------
#
#  PURPOSE:  This script accepts a full path to a file to back up,
#    and is responsible for 
#
#  EXPECTS:
#
#
#  RETURNS:
#    0     on success,
#    1     when too few arguments are passed,
#    2     when file to back up doesn't exist,
#    3     when file to back up can't be read,
#    4     when back-up directory can't be found or created,
#    5     when non-directory file exists with back-up directory name,
#    6     when back-up directory can't be written,
#    7     when copying file to back up fails,
#    8     when writing to back-up log file fails,
#
#
#  TO DO:
#
#    [ ] Display diagnostic messages via a local script function or
#        script library function, to permit global enabling and
#        disabling.
#
#---------------------------------------------------------------------



function usage__back_up_file()
{
    echo "Usage of script function 'back_up_file':"
    echo
    echo "    back_up_file [filename] [back-up-identifier]"
    echo
    echo "where filename identifies the file to be backed up,"
    echo "and 'back-up-identifier' is an identifying string from"
    echo "the calling script, chosen so that multiple files of"
    echo "a particular back-up job can be restored together."
}




function back_up_dir__set_by_library_script()
{
#---------------------------------------------------------------------
# PURPOSE:  provide name of back-up dir to library script functions 
#   and potentially external script functions.  Provide a script-wise
#   structure to permit single location to define important back-up
#   related variable.
#
# EXPECTS:  nothing
#
# RETURNS:  path to back-up directory for Debian post-install and
#   configure project.
#---------------------------------------------------------------------

    echo "./back-ups"
}




function save_to_back_up_dir()
{
#---------------------------------------------------------------------
# PURPOSE:  save requested file in back-up directory without changing
#   the filename,
#
# EXPECTS:  name of file to store in back-up directory,
#
# RETURNS:  result of executed file copy command,
#---------------------------------------------------------------------

    local dir__back_ups=$(back_up_dir__set_by_library_script)
    local debug_option=0
    local fname="save_to_back_up_dir"

#    imsg ${debug_option} ${fname} "saving $1 in ${dir__back_ups} . . ."
    show_info ${debug_option} ${fname} "saving $1 in ${dir__back_ups} . . ."
    cp $1 ${dir__back_ups}

#    imsg ${debug_option} ${fname} "copy command returned $?, returning to caller . . ."
    show_info ${debug_option} ${fname} "copy command returned $?, returning to caller . . ."
    return $?
}




function back_up_file()
{
    local dir__back_ups=$(back_up_dir__set_by_library_script)
    local file__log__back_ups="${dir__back_ups}/log-of-back-ups.txt"
    local time_stamp="TIMESTAMP-UNSET"
    local file__back_up="${dir__back_ups}/$1${time_stamp}"

    local warning="WARNING! "
    local fname="back_up_file"


#  STEP:  check that we have at least one argument

    if [[ $# -lt 2 ]]; then
       echo "${fname}:  received too few arguments from calling code,"
       usage__back_up_file
       return 1;
    fi


#  STEP:  check that file to back up exists

    if [[ ! -e $1 ]]; then
        echo "${fname}:  file '$1' does not exist"
        return 2;
    fi


#  STEP:  check that file to back up is readable

    if [[ ! -r $1 ]]; then
        echo "${fname}:  permission to read '$1' not set"
        return 3;
    fi


#  STEP:  check that back-up directory exists and is writeable

    if [[ ! -e ${dir__back_ups} ]]; then
        mkdir ${dir__back_ups}
        if [[ $? -ne 0 ]]; then
            echo "${fname}:  can't create back-up directory '${dir__back_ups}',"
            return 4;
        else
            echo "${fname}:  created back-up directory '${dir__back_ups}',"
        fi
    fi

    if [[ ! -d ${dir__back_ups} ]]; then
        echo "${fname}:  '${dir__back_ups}' exists but is not a directory,"
        return 5;
    fi

    if [[ ! -w ${dir__back_ups} || ! -x ${dir__back_ups} ]]; then
        echo "${fname}:  back-up directory exists but is not writeable,"
        return 6;
    fi


#  STEP:  back up the file

    time_stamp=`date +--%Y-%m-%d-%H:%M:%S`
    file__back_up="${dir__back_ups}/`basename $1`${time_stamp}"
    echo "${fname}:  copying '$1' to "${file__back_up}""

#---------------------------------------------------------------------
# Note:  Unix command cp appears to return 1 for several kinds of
#   copy errors.
#---------------------------------------------------------------------
    cp $1 ${file__back_up}

    if [[ $? -ne 0 ]]; then
        echo "${fname}:  ${error_string} failed to copy file for back-up purposes!"
        return 7;
    fi


#  STEP:  note latest back-up in the local back-up log
#
# Fields in back-up log file:  [back-up identifier] [full path to original file] [back-up file]"

    echo "$2,, $1,, ${file__back_up}" >> ${file__log__back_ups}

    if [[ $? -ne 0 ]]; then
        echo "${fname}:  ${warning} could't write back-up log file '${file__log__back_ups}',"
        echo "${fname}:  ${warning} won't have way to restore back-up file in the future,"
        return 9;
    fi

    return 0;
}



function restore_files_from_back_up()
{
#---------------------------------------------------------------------
#  2008-07-17
#  This function will likely read the log of back-up jobs, run grep on
#  that log file to select archives of a particular back up job, and
#  use awk to parse data on a per-column basis.
#---------------------------------------------------------------------

    echo "WARNING:  function restore_files_from_back_up() not yet implemented."
    return 1;
}
