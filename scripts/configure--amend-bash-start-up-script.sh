##====================================================================
##
##  PROJECT:  installs-de-alta
##
##  FILENAME:  configure--amend-bash-rc-start-up-script.sh
##
##  DESCRIPTION:
##    Bash shell routine to amend the Debian package sources list
##    file /etc/apt/sources.list by adding additional sources to an
##    existing file.  Also makes a copy of the original file,
##    appending time-of-copy time stamp to the filename.
##     
##     
##  NOTES:  For more information about this project be sure to read
##    the files 'ChangeLog' and 'Overview' in the doc directory of
##    this project.
##
##
##  NEED TO . . .
##    2018-02-01 - Need to add text processing so this script checks
##    whether user's dot bashrc file has already been modified
##    with the script sourcing lines to source the file named
##    'dot-bashrc-amendments.sh"  - TMH
##
##
##  AUTHORS AND MAINTAINERS:
##    Ted Havelka     ted@cs.pdx.edu     (TMH)
##
##
##====================================================================



function amend_bash_start_up_script()
{
##--------------------------------------------------------------------
##  Note:  'sources file' refers to Debian's APT package sources
##    list file, typically located in /etc/apt/.
##--------------------------------------------------------------------

# This shell routine checks the following directories, relative to
# itself, for a couple of files to use in amending a given user's
# .bashrc start up file:

    local list_of_source_directories=". ./scripts ../scripts"

    local source_file_to_append="source-statements-to-append-to-dot-bashrc"
    local source_file_to_copy="dot-bashrc-amendments.sh"
    local list_of_shell_amending_files="$source_file_to_append $source_file_to_copy"
    local path_and_source_file_to_append=""
    local path_and_source_file_to_copy=""

    local destination_dir="/home/${USER}"
    local destination_file=".bashrc"
    local file_to_amend

#    local source=${src_dir}/${src_file_to_append}
#    local destination=${dest_dir}/${dest_file}
    local users_dot_bashrc_file="$destination_dir/$destination_file"

    local time_stamp="TIMESTAMP-UNSET"
    local flag_continue=1


# diagnostics:

    local rname="amend_bash_start_up_script"

    local dflag_info="verbose"  # [ verbose|silent ] defined here for now as of 2018-02-05 - TMH



## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## - STEP - check whether user is 'root and if yes prompt user
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ ${USER} = 'root' ]]; then
    {
        echo "NOTE:  This script called by 'root' user, to install a directory book-marking extension to the bash shell.  This feature allows a user to store paths to directories they want to bookmark and avoid typing out at length.  But this bash extension stores bookmarked directories to a local text file in the user's home directory, leaving some evidence of paths which the user ostensibly cares about.  May be a security consideration for root users.  Are you sure you want this script to amend ${USER}'s ${destination_file} file and add some shell script to provide directory / full path bookmarking?  Please enter 'y' or 'n' (y/N):"
        read response
        if [ ${response} = 'n' -o ${response} = 'N' ]; then
        {
            show_info $rname "leaving root bash start-up file untouched and bash features not amended." $dflag_bashrc_amendments
            return
        }
        else
        {
            show_info $rname "continuing on to amend user ${USER} bash shell with directory bookmarking features," $dflag_bashrc_amendments
        }
        fi
    }
    fi



## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## - STEP - confirm that source files exist
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    show_diag_sh $rname "looking for files '$list_of_shell_amending_files' . . ." $dflag_bashrc_amendments
    show_diag_sh $rname "" $dflag_bashrc_amendments

    local n=0

#    if [ ]; then
#        for file in $list_of_shell_amending_files; do
#            for directory in $list_of_source_directories; do
#                if [ -e $directory/$file ]; then
#                    show_diag_sh $rname "$((n+1))) found file '$directory/$file',"  $dflag_bashrc_amendments
#                    ((n += 1))
#                    break
#                fi
#            done
#        done
#    fi


    show_diag_sh $rname "looking for lines to append to user's .bashrc file . . ." $dflag_bashrc_amendments

    if [ 1 ]; then
            for directory in $list_of_source_directories; do
                if [ -e $directory/$source_file_to_append ]; then
                    show_diag_sh $rname "$((n+1))) found file '$directory/$source_file_to_append'," $dflag_bashrc_amendments
                    path_and_source_file_to_append=$directory/$source_file_to_append
                    ((n += 1))
                    break
                fi
            done
    fi


    show_diag_sh $rname "looking for file of extra shell aliases to copy to user's home directory . . ." $dflag_bashrc_amendments

    if [ 1 ]; then
            for directory in $list_of_source_directories; do
                if [ -e $directory/$source_file_to_copy ]; then
                    show_diag_sh $rname "$((n+1))) found file '$directory/$source_file_to_copy'," $dflag_bashrc_amendments
                    path_and_source_file_to_copy=$directory/$source_file_to_copy
                    ((n += 1))
                    break
                fi
            done
    fi


    show_diag_sh $rname "found $n files needed by this shell function," $dflag_bashrc_amendments
# echo $id "RETURNING EARLY, SCRIPT DEVELOPMENT IN PROGRESS . . ."
#    return

    if [ $n != 2 ]; then
        show_diag_sh $rname "- WARNING - missing one or more bash amendments files!" $dflag_bashrc_amendments
        show_diag_sh $rname "- WARNING - not able to amend user ${USER}'s .bashrc amendments file," $dflag_bashrc_amendments
        show_diag_sh $rname "- WARNING - returning early to calling script . . ." $dflag_bashrc_amendments
        return
    else
        show_diag_sh $rname "found all files to extend bash shell with aliases and more," $dflag_bashrc_amendments
    fi
       


##----------------------------------------------------------------------
## - STEP - determine whether .bashrc file exists
##----------------------------------------------------------------------

    if [[ ${USER} = 'root' ]]; then
        file_to_amend="/${USER}/.bashrc"
    else
        file_to_amend="/home/${USER}/.bashrc"
    fi

    if [ -e $file_to_amend ]; then
        show_info $rname "found bash run-time config file '$file_to_amend' in ${USER}'s home directory," $dflag_bashrc_amendments
    else
        show_diag_sh $rname "- WARNING - no bash rc file found, user may not have bash as default shell, or bash may not be installed on the local host!"  $dflag_bashrc_amendments
    fi



##-----------------------------------------------------------------------
## - STEP - if needed create a back-up copy of user's .bashrc file
##-----------------------------------------------------------------------

    if [ -e $file_to_amend ]; then
    {
        time_stamp=`date +--%Y-%m-%d--%H-%M-%S`
        show_diag_sh $rname "creating timestamp string '$time_stamp'," $dflag_bashrc_amendments

#    if [[ ${USER} = 'root' ]]; then
#        local query_for_pattern_1=`grep BASH_RUNTIME_CONFIG_AMENDMENTS_FILE_2 /${USER}/.bashrc`
#        local query_for_pattern_2=`grep dot-bashrc-amendments.sh /${USER}/.bashrc`
#    else
#        local query_for_pattern_1=`grep BASH_RUNTIME_CONFIG_AMENDMENTS_FILE_2 /home/${USER}/.bashrc`
#        local query_for_pattern_2=`grep dot-bashrc-amendments.sh /home/${USER}/.bashrc`
#    fi

# echo "- zztop - calling grep with file argument '$file_to_amend' . . ."
        local query_for_pattern_1=`grep BASH_RUNTIME_CONFIG_AMENDMENTS_FILE_2 $file_to_amend`
# echo "- zztop - calling grep second time . . ."
        local query_for_pattern_2=`grep dot-bashrc-amendments.sh $file_to_amend`

        if [ -z "$query_for_pattern_1" ] && [ -z "$query_for_pattern_2" ]
        then
        {
#            show_diag_sh $rname "backing up user ${USER}'s as-found .bashrc file, copying to $users_dot_bashrc_file.$time_stamp . . ." $dflag_bashrc_amendments
            show_diag_sh $rname "copying '${file_to_amend}' to '${file_to_amend}${time_stamp}'" $dflag_bashrc_amendments
            cp ${file_to_amend} "${file_to_amend}${time_stamp}"

            show_diag_sh $rname "appending a few lines to user's .bashrc file, to source shell aliases . . ." $dflag_bashrc_amendments
            cat $path_and_source_file_to_append >> ${file_to_amend}
        }
        else
        {
            show_diag_sh $rname "For user '${USER}', dot bashrc file '$users_dot_bashrc_file' appears to be already" $dflag_bashrc_amendments
            show_diag_sh $rname "amended to call separate amendments and dir-bookmarking script." $dflag_bashrc_amendments
        }
        fi
    }
    else
    {
        show_info $rname "- WARNING - no .bashrc file found!" $dflag_bashrc_amendments
        show_info $rname "+  Note that bash command interpreter may not be user ${USER}'s default shell," $dflag_bashrc_amendments
        show_info $rname "+  or may not be installed on this host." $dflag_bashrc_amendments 
        show_info $rname "- INFO - creating a .bashrc file with enough information" $dflag_bashrc_amendments 
        show_info $rname "+  to source entending aliases and directory bookmarking feature . . ." $dflag_bashrc_amendments 
        cp $path_and_source_file_to_append $users_dot_bashrc_file
    }
    fi


## HERE CHECK IF DOT-BASHRC-AMENDMENTS FILE EXISTS, AND WHEN YES
## WHETHER IT IS UP-TO-DATE . . .

    if [ -e /home/${USER}/${source_file_to_copy} ]; then
        diff /home/${USER}/${source_file_to_copy} $path_and_source_file_to_copy > /dev/null
        result_of_diff=$?
        show_diag_sh $rname "diff of user ${USER}'s and this script's dot-bashrc-amendments files returns $result_of_diff," $dflag_bashrc_amendments
        show_diag_sh $rname "this means files match, no need to copy '$path_and_source_file_to_copy' to user's homedir," $dflag_bashrc_amendments
        if [ $result_of_diff = '1' ]; then
        {
            show_diag_sh $rname "amending Debian package sources list file . . ." $dflag_bashrc_amendments
            cp $path_and_source_file_to_copy $destination_dir
        }
        fi
    else
        echo "copying '$path_and_source_file_to_copy' to '$destination_dir' . . ."
        cp $path_and_source_file_to_copy $destination_dir
    fi


    show_diag_sh $rname "returning to caller . . ." $dflag_bashrc_amendments
}
