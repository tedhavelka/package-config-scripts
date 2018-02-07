##======================================================================
##
##  PROJECT:  'Installs de Alta' package config scripts
##
##  FILENAME:  read-packages.sh
##
##     
##  DESCRIPTION:  read Debian software package names from a text
##    file.  provide various selection and filtering options to build
##    package lists suitable for Linux system geared toward use as,
##
##    +  software development, end-user desktop stations,
##    +  mail and database servers,
##    +  functional low-end hardware stations,
##     
##     
##  TO-DO:
##     
##    [ ]  2018-02-05 MON - add support for multiple package 'recipes',
##         such as desktop server versus LAMP or web server package
##         sets,
##     
##     
##  NOTES ON IMPLEMENTATION: . . .
##     As of 2018-02-06 this script reads one text file to build a
##   recipe or list of Debian packages to install on a given Linux
##   host.  The filename is defined locally.  To support alternate
##   system recipes or sets of packages, a simple way to do so would
##   be to have configuration recipes in named files.  Some example
##   config recipe filenames could be . . .
##
##     *  packages-software-development.txt
##     *  packages-LAMP-server.txt
##     *  packages-graphics-and-media.txt
##
##
##
##
##
##
##   For more information about this project be sure to read
##   the files 'ChangeLog' and 'Overview' in the doc directory of
##   this project.
##
##     
##  AUTHORS AND MAINTAINERS:
##     
##    Ted Havelka     ted@cs.pdx.edu     (TMH)
##
##
##     
##     
##======================================================================





function read_packages()
{

    local id="read_packages:  "

    if [ -d ./data ]; then
        directory_for_data="./data"
    elif [ -d ../data ]; then
        directory_for_data="../data"
    else
        echo ${id} "WARNING - could not locate installs-de-alta"
        echo ${id} "WARNING - data directory.  Unable to read"
        echo ${id} "WARNING - post-install packages list."
        return
    fi


    filename_for_package_list="packages--post-install.txt"
    filename=${directory_for_data}/${filename_for_package_list}
    packages="DEFAULT"
    index=1


##
## 2016-04-14 - CAN'T PUT ECHO STATEMENTS HERE, AS THEY INTERFERE
##   WITH VALUES THIS ROUTINE RETURNS BY GETTING MIXED IN WITH 
##   THOSE FILE-PARSED RETURN VALUES . . .  - TMH
##
##    echo ${id} "-- 2016-04-14 THU --"
##    echo ${id} "parsing text file '${filename}' for Debian style packages to check or install . . ."
##

    packages=`grep -v \# ./${filename} | awk '{print $1}'`

# echo "Variable packages holds:  ${packages}"

    for package in ${packages}; do
        if [ ${index} -gt 1 ]; then
            packages="${packages} ${package}"
        else
            packages="${package}"
        fi
        let "index += 1"
    done

    echo ${packages}

}




function build_base_package_list()
{
    result=$(read_packages)
    echo ${result}
}




## --- EOF ---
