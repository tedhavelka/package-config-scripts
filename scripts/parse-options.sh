##======================================================================
##
##  PROJECT:  installs-de-alta
##
##  FILENAME:  parse-options.sh
##
##  DESCRIPTION:  see . . .
##
##  AUTHORS AND MAINTAINERS:
##
##    Ted Havelka     ted@cs.pdx.edu     (TMH)
##
##======================================================================


#---------------------------------------------------------------------
# Note:  built-in variable $@ holds all the values of variables
#  that appear immediately following the call to this function.
#  Among the positional variables, however, $0 $1 $2 . . . the first
#  of these is still assigned the name of the script itself, while
#  successive positionals point to each token in the $@ array whose
#  context here is this function's code block.
#---------------------------------------------------------------------

function option_present()
{
#---------------------------------------------------------------------
# This function expects these passed parameters:
#
#    arg[0]   script option for which to search,
#    arg[1]   argument list from command line,
#
# and string returns one of the values,
#
#    "true"  . . . option found among command line arguments,
#    "false"  . . . option not found,
#
#---------------------------------------------------------------------

# Passed variables:
    local id="option_present"      #
    local option_to_find=$1        # $1 is first passed parameter,
    local option_prefix="\-\-\-"   #

# Integer variables:
    local index=0

# String variables:
    local token      # ...arguments in this function's instance of argv,
    local pattern    # ...local temp string for readability,
    local result     # ...holds boolean result of search,

    result="false"

#---------------------------------------------------------------------
# STEP:  set the option prefix based on the length of the option.
#  single-character options are preceded by single dashes, long form
#  options are preceded by double dashes
#---------------------------------------------------------------------

    if [[${#option_to_find} = 1]]; then
        option_prefix="\-"
    else
        option_prefix="\-\-"
    fi

    dmsg "${id}:  setting option prefix to '${option_prefix}',"


#---------------------------------------------------------------------
# STEP:  parse tokens past script name and single passed parameter
#---------------------------------------------------------------------

    for token in $@; do
        if [ ${index} -gt 2 ]; then  # ...skip the first two arguments
                                     # passed to this function

            pattern=${option_prefix}${option_to_find}
            dmsg "${id}:  comparing ${pattern} to ${token},"
            if [[ ${token} = ${pattern} ]]; then
                result="true"
            fi
        fi
        index=$((index + 1))
    done

    echo ${result}

}




function argument_from()
{
#---------------------------------------------------------------------
# PURPOSE:
#    Return the argument associated with a given script option
#    which calling code specifies.
#
# EXPECTS:
#    arg[0])  script option for which to search,
#    arg[1])  argument list from command line,
#
# RETURNS:
#    the the argument if the correct option, separating character
#    and argument are found.
#---------------------------------------------------------------------

# Passed variables:
    local option_to_find=$1

# Integer variables:
    local index=1

# String variables:
    local option_argument_separator="\="
    local token          # ...arguments in this function's instance of argv
    local pattern        # ...local temp string for readability
    local option_found   # ...holds match to desired option, if found
    local argument       # ...holds argument of desired option, if found

    local id="argument_from"

    dmsg_configure 0
    dmsg "${id}:  received '${option_to_find}',"

    for token in $@; do
        if [ "$index" -gt 1 ]; then
            pattern=${option_to_find}${option_argument_separator}
            dmsg "${id}:  index = '${index}',"
            dmsg "${id}:  comparing '${pattern}' with '${token}',"

            if (echo $token | grep -q ${pattern}); then
                dmsg "${id}:  found a matching option!"
                option_found=$(echo $token | grep ${pattern} | cut -d "=" -f 1)
                argument=$(echo $token | grep ${pattern} | cut -d "=" -f 2)
                break
            fi
        fi
        index=$((index + 1))
    done

    dmsg_configure 1

# Return script option and its argument:

    echo $argument

}
