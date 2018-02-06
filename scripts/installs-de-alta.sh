#!/bin/bash
# #!/bin/sh



##======================================================================
##
##  FILENAME:  installs-de-alta.sh
##
##  PURPOSE:  used to automate specific package installations on
##    Debian systems, following base install.  Taylored to the needs of
##    Veris Alta environmental sensors team.
##
##
##  REFERENCES:
##
##  From The Linux Documentation Project . . .
##
##    *  http://tldp.org/LDP/abs/html/arrays.html
##
##    *  http://www.tldp.org/LDP/abs/html/arithexp.html
##
##    *  http://tldp.org/LDP/abs/html/varsubn.html
##
##
##
##  AUTHORS AND MAINTAINERS:
##
##    Ted Havelka     ted@cs.pdx.edu     (TMH)
##
##======================================================================





#---------------------------------------------------------------------
#  SECTION:  script variables
#---------------------------------------------------------------------

filename__modules_list="/etc/modules"
filename__network_config="/etc/dhcp3/dhclient.conf"



#---------------------------------------------------------------------
# SECTION:  helping scripts
#
# Note unlike several script files which this main installer script
# sources and which contain only shell functions, the scripts
# assigned to variables here are complete, stand-alone scripts
# capable of executing via user-invocation at the command line.
#---------------------------------------------------------------------

script_to_link_sound_device="./link-sound-device --install"



#
## 2016-04-13 WED - following assignment of value in parentheses
##  generates an error.  Ted noting also that stable, testing and
##  unstable are Debian distribution terms, but may not be in use or
##  mean quite the same thing in Ubuntu/Canonical's Linux
##  distribution:                                                - TMH
##
##  Some notes from http://tldp.org/LDP/abs/html/varsubn.html:
##
##
##  hello="A B  C   D"
##  echo $hello   # A B C D
##  echo "$hello" # A B  C   D
##  # As we see, echo $hello   and   echo "$hello"   give different results.
##  # =======================================
##  # Quoting a variable preserves whitespace.
##  # =======================================
##
##
##
##
##
#

# distributions=(stable testing unstable)
distributions="stable testing unstable"

# Declaring an array in the shell script:

## 2016-04-13 - keyword 'declare' not found . . . strange that this
##  worked a few years ago - TMH

#
## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
## declare -a tokens   # Note:  couldn't get a function to pass
                    # multiple values back to this variable,
                    # need to resolve syntax or or code
                    # implementation there . . . TMH

## 2018-20-05 ^^^ above problem may be solved by double-quoting the
##  values which are assigned to a variable that gets returned to
##  calling script code - TMH
## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#


# Debugging and diagnostic strings:

warning1="warning"



#=====================================================================
#  SECTION:  script functions
#=====================================================================

function usage()
{
    echo
    echo "Usage for script ${scriptname}:"
    echo
    echo "${scriptname} [ --action=[show-packages | test | install | none]] "
    echo "   [ --distribution=[ stable | testing ]] "
    echo "   [ other options ] "
    echo
    echo "Other options include:"
    echo
    echo "   -ab, --amend-bash-start-up-script"
    echo "   -as, --amend-sources-list"
    echo "   -c, --configure-cyclades"
    echo "   -p, --publish-hostname"
    echo "   -s, --configure-static-sound-device"
    echo "   --cc, --comment-cdrom-in-sources-list"
    echo
    echo "Options may appear in any order following the name of the package-installing script."
    echo
    echo "with the --action option, named actions include:"
    echo "  show-packages   . . . shows packages to be installed, those named in test file this script reads"
    echo "  test            . . . calls 'apt' in simulate mode, good for testing and doesn't install anything"
    echo "  install         . . . calls 'apt' to install the named packages and their dependencies"
    echo "  none            . . . script aliases rm, cp and mv to run interactively but does nothing else"
    echo
}




check_user_is_root()
{
#---------------------------------------------------------------------
# 2007-09-21
# This function checks whether the root user has invoked this script.
# If the script is run by an alternate user it stops here to notify
# the user, providing an opportunity for the user to exit early and
# switch users to an administrative user.  - TMH
#
# Note:  this code copied from the px-pgm install script named
# 'install-px-pgm.sh'.  - TMH
#---------------------------------------------------------------------

    local rname="check_user_is_root"  # function identifier for debugging,
    local response="n"             # holds user input,
    local message_formatting=0

    if [ "root" != `whoami` ]; then
#        dmsg "$rname:  WARNING - running after invocation by non-root user,"
        dmsg "$rname:  - WARNING - this package configurations script running with privileges"
        dmsg "$rname:   of a non-root user.  Some install actions likely require root priveleges."
        dmsg "$rname:   Do you wish to stop script and rerun as the root user?  [Y/n]"
#        dmsg " "
        read response
#        dmsg " "
        if [ ${response} = 'Y' -o ${response} = 'y' ]; then
            dmsg "$rname:  exiting early to permit user to change effective user . . . done."
            exit 0
        else
            show_info $rname "continuing . . ." $message_formatting
        fi
    fi
}




alias_file_modifying_commands()
{
    local id="alias_file_modifying_commands"

    dmsg "${id}:  aliasing file modifying commands rm, cp, mv to run interactively . . ."
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
}




function add_packages_for_distro_stable()
{
#---------------------------------------------------------------------
# Note:  no indentation in this function to avoid extra white space
#   in the variable to hold package names.
#---------------------------------------------------------------------

packages="${packages} \
$pkgs_database_stable \
$pkgs_documentation_stable \
$pkgs_fonts_stable \
$pkgs_graphic_env_stable \
$pkgs_media_stable \
$pkgs_qt_stable \
"
}


function add_packages_for_distro_testing()
{
packages="${packages} \
$pkgs_database_testing \
$pkgs_fonts_testing \
$pkgs_graphic_env_testing \
$pkgs_media_testing \
"
}


function add_transcoded_font_packages()
{
    for font in $pkgs_fonts_transcoded; do
        echo "Adding to install list '${font}-transcoded',"
        packages=" ${packages} ${font}-transcoded"
    done
}




function show_packages_to_install()
{
    for package in $packages; do
        echo $package
    done
}




#=====================================================================
#  SECTION - main line code, script execution begins here:
#=====================================================================

scriptname=`basename $0`   # script identifier for debugging,
id="main"                  # function identifier for debugging,

## 2018-02-02 - Ted updating this script after some years' time, may
##  rename and make a few changes to the diagnostis and development
##  message handling scheme in this Bash project, hence addition of
##  shell variable $rname here:   - TMH
rname=$id


back_up_dir="./back-ups"   # back-up directory for config files,
result=""                  # flag to hold result of function calls,

## 2018-02-02 - shell vars to make diagnostics more flexible:
dflag_verbose=
dflag_announce="diagnostics-on"
dflag_bashrc_amendments="diagnostics-on"



#---------------------------------------------------------------------
# STEP - source supporting script files:
#---------------------------------------------------------------------


## 2016-04-13 - updating script directory assigment to make
##  installs-de-alta.sh a little smarter . . .
##
## script_dir="./scripts"

if [ -f "${script_dir}/parse-options.sh" ]; then
    script_dir="./scripts"
else
    script_dir="."
fi


# ${script_dir}/configure--amend-bash-start-up-script.sh \

scripts_mission_critical="\
${script_dir}/diagnostics.sh \
${script_dir}/parse-options.sh \
${script_dir}/read-packages.sh \
"

scripts_configuration_helpers="\
${script_dir}/back-up-file.sh \
${script_dir}/configure--amend-bash-start-up-script.sh \
${script_dir}/configure--amend-sources-list.sh \
${script_dir}/configure--comment-cdrom-entry.sh \
${script_dir}/configure--hostname-publication.sh \
${script_dir}/configure--module-for-cyclades.sh \
"


# NEED to check for mission-critical scripts, such as parse-options.sh and read-packages.sh . . .

    scripts="${scripts_mission_critical} ${scripts_configuration_helpers}"

    for script in ${scripts}; do
        if [ -f ${script} ]; then
            if [ $dflag_verbose ]; then
                echo "sourcing helping script ${script} . . ."
            fi
            . ${script}
        else
            echo "WARNING - could not find ${script}, may not be able to"
            echo "WARNING - perform some install and/or configuration actions."
        fi
    done



#---------------------------------------------------------------------
# STEP - introductory message:
#---------------------------------------------------------------------

dmsg_configure 1 ${id}

show_diag_sh $rname "-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" $dflag_announce
show_diag_sh $rname "            \"Installs de Alta\" Package Configurations Script            " $dflag_announce
show_diag_sh $rname "-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" $dflag_announce
show_diag_sh $rname "Script starting," $dflag_announce
show_diag_sh $rname "this script intended to aid and automate Linux package installations," $dflag_announce
show_diag_sh $rname "and some specific device and program configurations." $dflag_announce
check_user_is_root
alias_file_modifying_commands


#---------------------------------------------------------------------
# STEP:  get user's requested distribution, or set default and
#   build appropriate list of packages to install:
#---------------------------------------------------------------------

# dmsg "${id}:  debugging parsing routine argument_from() . . ."
# argument_from "\-\-distribution" $@
# dmsg "${id}:  calling parsing routine argument_from() via assignment . . ."
distribution_requested=$( argument_from "\-\-distribution" $@ )

index=0

if [[ $distribution_requested = "" ]]; then
    distro=${distributions[0]} 
    dmsg "${id}:  no Linux distribution specified, defaulting to ${distro},"
else
    for distro in ${distributions[@]}; do
        dmsg "${id}:  comparing '$distribution_requested' with '${distro}',"
        if [ "$distribution_requested" = "$distro" ]; then
            dmsg "${id}:  found recognized distro = '$distribution_requested',"
            break
        fi
        index=$((index + 1))
    done
    dmsg "${id}:  user-requested distro '${distribution_requested}' has index '${index}',"

fi



##----------------------------------------------------------------------
## -- SECTION -- build list of named packages to install
##----------------------------------------------------------------------

#
## 2018-02-05 - NOTE:  this section and the function it calls will
##  need improvements and or changes, to support the notion of multiple
##  types of system package configuration, e.g.:  desktop software
##  development station, LAMP server, etc . . .   - TMH
#

if [ ]; then
    dmsg "${id}:  above distro-CASE statement,"
    dmsg "${id}:  script variable \$distro holds '${distro}',"
    dmsg "${id}:  script variable \$index holds '${index}',"
fi


case $index in
    0) # distro Debian stable
        dmsg "${id}:  building Alta package list for Debian '${distributions[0]}' installation,"
        packages=$( build_base_package_list )
        add_packages_for_distro_stable
        dmsg "${id}:  adding transcoded font packages to list of post-install packages,"
        add_transcoded_font_packages
        ;;

    1) # distro Debian testing
        dmsg "${id}:  building Alta package list for Debian '${distributions[1]}' installation,"
        packages=$( build_base_package_list )
        add_packages_for_distro_testing
        ;;

    2) # distro Debian unstable
        dmsg "${id}:  warning -- unstable Debian distro not yet supported,"
        ;;

    *)
        dmsg "${id}:  encountered unknown distribution '$distro'"
        dmsg "${id}:  please specify a Linux distribution among this list:"
        index=0
        for ((index=0; index < ${#distributions[*]}; index++)); do
            echo -n "$index)  "
            echo ${distributions[$index]}
        done
        action="none"
        ;;

esac

##----------------------------------------------------------------------
## STEP:  determine action to take.  Actions include,
##
##     *  show packages
##     *  simulate installation of packages
##     *  install packages
##
##  If there are no arguments to this script then set 'action' to a
##  default value of 'usage', so as to show the user what options are
##  available:
##----------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
    action="usage"
fi

#---------------------------------------------------------------------
# If there are arguments but among them no action specified for this
# script to take, then set the action to 'usage'.  This triggers the
# script to display valid script options:
#---------------------------------------------------------------------

action=$( argument_from "\-\-action" $@ )

if test -z ${action}; then
    dmsg "${id}:  no action specified by user, setting default action to 'usage',"
    action="usage"
fi


#{
    case ${action} in
        show-packages)
            echo ${packages}
        ;;


        "test")
            echo "calling apt-get in 'simulate mode' for testing purposes,"
            echo "( command in single quotes is 'apt-get --simulate install ${packages}' )"
            apt-get --simulate install ${packages}
        ;;


        "install")
            echo "calling apt-get to install additional packages . . ."
            apt-get install ${packages}
        ;;


        "none")
            dmsg "${id}:  user requests no action so doing nothing,"
        ;;


        *)
            usage
        ;;
    esac
#}


#---------------------------------------------------------------------
# STEP:  parse through options and perform requested configurations
#---------------------------------------------------------------------

for token in $@; do

    case ${token} in

        -ab|--amend-bash-start-up-script)
            amend_bash_start_up_script
        ;;

        -as|--amend-sources-list)
            amend_sources_list
        ;;


        -c|--configure-cyclades)
            configure_cyclades
        ;;

        --cc|--comment-cdrom-in-sources-list)
            comment_cdrom_in_sources_list "${back_up_dir}"
        ;;

        -p|--publish-hostname)
            enable_hostname_publication ${back_up_dir}
        ;;

        -s|--configure-static-sound-device)
            ${script_to_link_sound_device}
        ;;


# Handle non-configuration script options:

        --action*|--distribution*)
            dmsg "${id}:  skipping non-configuration option '${token}',"
        ;;


# Notify user when unknown options are encountered:

        *)
            dmsg "${id}:  script doesn't understand option '${token}',"
        ;;

    esac

done



dmsg "${id}:  done."
echo
exit 0
