#=====================================================================
#  Project:  installs-de-alta
#  Filename:  diagnostics.sh
#  Description:  diagnostic functions to aid development and
#    debugging of Ted's Debian installer and configuration script.
#=====================================================================


dmsg_format=1
calling_code_identifier="DEFAULT-CODE-IDENTIFIER"



function dmsg_configure()
{
#---------------------------------------------------------------------
# EXPECTS:
#     A diagnostics message format chosen by calling code.  Options
#     include,
#
#     0     . . . suppress diagnostic messages,
#     1     . . . show only message sent by calling code,
#     2     . . . prefix calling code message with fixed string,
#
# SETS:
#     dmsg_format              . . . global to this file,
#
# STILL NEEDS:
#     reasonable bounds and error checking
#---------------------------------------------------------------------

    dmsg_format=$1

}




function dmsg()
{
#---------------------------------------------------------------------
#
# PURPOSE:
#    To provide a within-script standard way of showing diagnostic
#    messages.
#
# EXPECTS:
#    *  message to display,
#
# RETURNS:
#    nothing
#
#---------------------------------------------------------------------

    local id="dmsg"


# Check for request to suppress diagnostic message output:

    if [[ ${dmsg_format} = "0" ]]; then
        return
    fi


# Display only the passed message:

    if [[ ${dmsg_format} = "1" ]]; then
       echo "$1"
    fi

}




function show_info()   # expects ($caller, $message, $options)
{
#---------------------------------------------------------------------
# 
#  PURPOSE:
#     Provide a within-script standard way to display informational
#     messages for end users.
# 
#  EXPECTS:
#     *  calling code identifier
#     *  message to display
#     *  options to format or to hide info message
#
#  RETURNS:
#     nothing
#
#
#  Formatting options include,
#
#     0   . . . display nothing,
#     1   . . . originating scriptname followed by passed message,
#     2   . . . passed function name followed by passed message,
#
#  By originating script Ted intends the name of the script invoked
#  which eventually calls this information/diagnostics function.
#
#  2008-06-19  This routine needs error checking added, - TMH
# 
#---------------------------------------------------------------------

    local caller=$1
    local message=$2
    local options=$3

    if [[ $options = 'silent' ]]; then
        return
    fi

    echo "$caller:  -- INFO -- $message"


} # end shell function show_info()




show_diag_sh()
{
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##  CALL WITH:  $caller, $message, $options
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    local caller=$1
    local message=$2

    echo "$caller:  $message"
}




#=====================================================================

function diagnostics_set_aside()
{

#---------------------------------------------------------------------
# 2007-09-21 FRI: used to display grep results of /etc/modules lines
#  containing pattern 'cyclades':
#---------------------------------------------------------------------

    count=0
    for token in ${result}; do
        echo "${count}) ${token}"
        ((count += 1))
    done


#---------------------------------------------------------------------
# 2007-09-21 FRI:  additional debugging for cyclades module routine:
#    echo "function configure_cyclades():  result = \'${result}\',"
#---------------------------------------------------------------------

    for token in ${result}; do
        echo "${count})  comparing ${pattern} to ${token},"
        if [[ ${token} = ${pattern} ]]; then
            action_to_take="do_nothing"
        fi
        ((count += 1))
    done


}
