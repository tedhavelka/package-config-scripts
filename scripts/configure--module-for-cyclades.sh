function configure_cyclades()
{
#---------------------------------------------------------------------
# PURPOSE:
#  This function checks whether there are any references to cyclades
#  modules in the /etc/modules files of a Debian Linux installation.
#  First two local variables are assigned values of global variables
#  defined above all function definitions.  - TMH
#
# EXPECTS:
#   *  name of file listing kernel modules loaded at boot time,
#
# RETURNS:
#   0     . . . on success,
#   > 0   . . . on failure,
#---------------------------------------------------------------------

    local filename=${filename__modules_list}
    local module_name="cyclades"
    local result
    local action_to_take="modify_file"
    local count=1
    local id="configure_cyclades"


    if [ -e ${filename} ]; then
        dmsg "${id}:  found modules file '${filename},"
    else
        dmsg "${id}:  warning -- modules file '${filename} not found,"
        dmsg "${id}:  warning -- unable to configure cyclades module to load at boot time,"
        return 1
    fi

    result=`grep ${module_name} ${filename}`

    for token in ${result}; do
        if [[ ${token} = ${module_name} ]]; then
            action_to_take="do_nothing"
        fi
        ((count += 1))
    done


    if [[ ${action_to_take} = "modify_file" ]]; then
        dmsg "${id}:  adding ${module_name} module reference to config file ${filename},"
        echo ${module_name} >> ${filename}
    else
        dmsg "${id}:  ${module_name} module present in config file ${filename},"
        dmsg "${id}:  not modifying ${filename},"
    fi

    return 0
}
