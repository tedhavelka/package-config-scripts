#=====================================================================
#
#  PROJECT:  installs-de-alta
#
#  FILENAME:  configure--amend-sources-list.sh
#
#  DESCRIPTION:
#    Bash shell routine to amend the Debian package sources list
#    file /etc/apt/sources.list by adding additional sources to an
#    existing file.  Also makes a copy of the original file,
#    appending time-of-copy time stamp to the filename.
#     
#  AUTHORS AND MAINTAINERS:
#    Ted Havelka     ted@cs.pdx.edu     (TMH)
#
#
#  NOTES:  For more information about this project be sure to read
#    the files 'ChangeLog' and 'Overview' in the doc directory of
#    this project.
#
#=====================================================================



function amend_sources_list()
{
#---------------------------------------------------------------------
# Note:  'sources file' refers to Debian's APT package sources
#   list file, typically located in /etc/apt/.
#---------------------------------------------------------------------

    local src_dir="./data"
    local src_file="additional-sources.list"

    local dest_dir="/etc/apt"
    local dest_file="sources.list"

    local source=${src_dir}/${src_file}
    local destination=${dest_dir}/${dest_file}

    local time_stamp="TIMESTAMP-UNSET"
    local flag_continue=1
    local id="amend_sources_list:  "


#---------------------------------------------------------------------
# STEP - confirm source and destination files exist
#---------------------------------------------------------------------

    flag_continue=1

    if [ -f $source ]; then
        if [ -f $destination ]; then
            flag_continue = 0
        else
            echo $id "WARNING - can't find package sources list file '" $destination "',"
            echo $id "WARNING - unable to add more sources to this file,"
        fi
    else
        echo $id "WARNING - can't find file with additional package sources '" $source"',"
        echo $id "WARNING - unable to add more sources to '" $destination "',"
    fi

    if [ flag_continue -ne 0 ]; then
        return
    fi
       

#---------------------------------------------------------------------
# STEP - make copy of sources.list file named with present time-stamp
#---------------------------------------------------------------------

    time_stamp=`date +%Y-%m-%d--%H:%M:%S`
    dmsg "${id}:  creating timestamp string '${time_stamp}',"

    echo $id "backing up Debian package sources list file . . ."
    cp ${destination} ${destination}.${time_stamp}

    echo $id "amending Debian package sources list file . . ."
    cat ${source} >> ${destination}

    echo $id "done, returning to caller . . ."
}
