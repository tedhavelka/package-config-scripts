#=====================================================================
#
#  PROJECT:  installs-de-alta
#
#  FILENAME:  configure--comment-cdrom-entry.sh
#
#  DESCRIPTION:
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



function comment_cdrom_in_sources_list()
{
# Note:  'sources file' refers to Debian's APT package sources
#   list file, typically located in /etc/apt/.
#---------------------------------------------------------------------

    local dir__sources_file="/etc/apt"
    local dir__back_ups="./back-ups"
    local time_stamp="TIMESTAMP-UNSET"
    local file__sources__name="sources.list"
    local file__sources__full_path="${dir__sources_file}/${file__sources__name}"
    local file__sources__back_up="${dir__back_ups}/${file__sources__name}.TIMESTAMP"
    local file__sources__modified="${dir__sources_file}/${file__sources__name}.modified"

    local id="comment_cdrom_in_sources_list"

#---------------------------------------------------------------------
# STEP:  prepare back-up directory
#
# If no args are passed to this function then set the back-up
# directory to the locally defined value:
#---------------------------------------------------------------------

    [ $# -eq 0 ] && dir__back_ups=${dir__back_ups} || dir__back_ups=$@
    dmsg "${id}:  back-up file directory set to '${dir__back_ups}',"

    if [ -d ${dir__back_ups} ]; then
        dmsg "${id}:  found back-up directory '${dir__back_ups}'"
        flag__back_up_dir_ready=0
    else
        mkdir ${dir__back_ups}
        flag__back_up_dir_ready=$?
    fi

    if [[ ${flag__back_up_dir_ready} ]]; then
        dmsg "${id}:  couldn't create back-up directory '${dir__back_ups}',"
    fi


#---------------------------------------------------------------------
# STEP:  create back-up
#---------------------------------------------------------------------

    time_stamp=`date +%Y-%m-%d--%H:%M:%S`
    dmsg "${id}:  creating timestamp string '${time_stamp}',"

    file__sources__back_up=$(echo ${file__sources__back_up} | sed 's/TIMESTAMP//')
    file__sources__back_up=${file__sources__back_up}${time_stamp}
#    dmsg "${id}:  back up filename set to '${file__sources__back_up}',"
#    dmsg "${id}:  about to execute:"
#    dmsg "${id}:  cp ${file__sources__full_path} ${file__sources__back_up}"

    dmsg "${id}:  copying '${file__sources__full_path}' to '${file__sources__back_up}',"
    cp ${file__sources__full_path} ${file__sources__back_up}


#---------------------------------------------------------------------
# Note:
#    echo "deb cdrom:[Debian GNU/Linux 4.0 r0 _Etch_ - Official i386\
# NETINST Binary-1 20070407-11:29]/ etch contrib main" | sed \
# 's/\(deb cdrom\)\(.*\)/\# \1\2/'
#---------------------------------------------------------------------

    file__sources__modified="${dir__back_ups}/${file__sources__name}.modified"
    sed 's/\(deb cdrom\)\(.*\)/\# \1\2/' < ${file__sources__full_path} > ${file__sources__modified}

    dmsg "${id}:  \$file__sources__modified = ${file__sources__modified}"

}
