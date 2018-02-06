#=====================================================================
#
#  PROJECT:  installs-de-alta
#
#  FILENAME:  configure--hostname-publication.sh
#
#  DESCRIPTION:
#    Shell script function to modify DHCP configuration file to
#    permit hostname publication.  Default config under Debian is
#    no hostname publication.
#     
#  AUTHORS AND MAINTAINERS:
#    Ted Havelka     ted@cs.pdx.edu     (TMH)
#
#  SEE ALSO:
#    For more information about this project be sure to read the
#    files 'ChangeLog' and 'Overview' in the doc directory of this
#    project.
#
#=====================================================================



function enable_hostname_publication()
{
#---------------------------------------------------------------------
#
#  PURPOSE:
#    To modify DHCP configuration file to permit hostname publication.
#
#  EXPECTS:
#
#    *  string to identify back-up job of file to be modified,
#
#  RETURNS:
#
#    0    on success,
#    1    if no back-up job identifier received from calling code,   
#    2    if config file needs no modification,
#    3    if back-up fails,
#    4    if copying modified file over original file fails,
#
#---------------------------------------------------------------------

    local config_dir="/etc/dhcp3"
    local config_file="dhclient.conf"
    local file_to_modify="${config_dir}/${config_file}"
    local temp_file_name="${config_file}-modified"
    local back_up_job=""    # passed by calling code
    local dir__back_ups=""
    local line=""
    local host_name=`hostname -f`

# ${back_up_job} is string to identify the group of files with which original DHCP file is saved,
# ${dir__back_ups} names directory for "fall back" saving of modified DHCP file,
# ${line} temporary local string,
# ${host_name} holds . . .

    local debug_option=2
    local id="enable_hostname_publication"

    dmsg "${id}:  hostname determined to be ${host_name},"


#---------------------------------------------------------------------
# STEP:  check that the function is called with at least one argument
#---------------------------------------------------------------------

    if [[ $# -lt 1 ]]; then
        dmsg "${id}:  calling code hasn't sent string to identify back-up job,"
        dmsg "${id}:  \$1 holds '$1',"
        dmsg "${id}:  returning without modifying any config files . . ."
        return 1
    else
        back_up_job=$1
    fi

#---------------------------------------------------------------------
# STEP:  check whether dhcp config file needs modification
#---------------------------------------------------------------------

#    ( grep -n '^send host-name [^ ]*' ${file_to_modify} ) > /dev/null 2>&1
    line=`grep -n '^send host-name [^ ]*' ${file_to_modify}`
    if [[ $? -eq 0 ]]; then
        host_name_in_file=`echo "${line}" | awk -F\" '{print $2}'`
        dmsg "${id}:  config file '${file_to_modify}' already set to publish hostname '${host_name_in_file}',"
        dmsg "${id}:  not modifying '${file_to_modify}',"
        return 2
    fi

#---------------------------------------------------------------------
# STEP:  call back-up function
#---------------------------------------------------------------------

    dmsg "${id}:  calling function to back up file with args '${file_to_modify}', '${back_up_job}' . . ."
    back_up_file ${file_to_modify} ${back_up_job}
    if [[ $? -ne 0 ]]; then
        dmsg "${id}:  trouble backing up config file '${file_to_modify}'!"
        return 3;
    fi

#---------------------------------------------------------------------
# STEP:  modify DHCP configuration file
#---------------------------------------------------------------------

    sed 's/\(#\)\(send host-name \)\([^ ]*\)/\1\2\3\n\2\"'"${host_name}"'\";/' < ${file_to_modify} > ${temp_file_name}
    cp ${temp_file_name} ${file_to_modify}
    if [[ $? -ne 0 ]]; then
        dmsg "${id}:  unable to copy modified file over original file,"
        dmsg "${id}:  saving modified file in back-up directory . . ."
        temp_file_name=`basename ${temp_file_name}`
        save_to_back_up_dir ${temp_file_name}
        dir__back_ups=$(back_up_dir__set_by_library_script)
        dmsg "${id}:  compare ${dir__back_ups}/${temp_file_name} with ${file_to_modify},"
        return 4
    fi

    return 0
}
