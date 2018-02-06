##======================================================================
##                   "Installs de Alta" Project
##======================================================================



-- OVERVIEW --

Files, plus directories and their files along side this readme, are a collection of scripts and text files used to automate package configuration of Debian and Ubuntu based Linux work stations.  These scripts and their supporting data files focus on configuring Linux hosts which provide but are not limited to:


   *  XForms libraries
   *  Qt libraries and editor
   *  gcc and GNU C compilation toolchain
   *  openssh server
   *  select mathematical packages



-- THE PRIMARY SCRIPT TO CALL --

The primary script in this project is named installs-de-alta.sh, and is located in ./scripts.  Installs-de-alta.sh was last tested, and its packages list updated manually, in summer of 2017.  Installs-de-alta.sh is used to install user-space packages following a successful base Linux install, typically an install on a desktop or server type computer.

Over time Linux distribution software packages change in name, number and sometimes factoring.  For this reason the text file of this project which lists packages to install, located in ./data/packages--post-install.txt needs to be kept up to date manually.  This is an important task, but also normally a small infrequent task.  Over the years of development and use of installs-de-alta, project maintainers find that normally only a few packages, from one to three packages in the local list, typically changes over the course of a year.

Bigger changes to installs-de-alta additional packages list, however, are definitely needed when moving this script's use from one major Linux distribution release to another release, e.g. Ubutnu 16.04 LTS ==> Ubuntu 18.04 LTS.



-- SEEING THE USAGE MESSAGE --

Invoking installs-de-alta.sh with no arguments will lead to a prompt, where the script asks if you want to run this script as root.  For real, not simulated package installations, its generally necessary to run this script on Debian-like systems as the root user.  Answering "no" at this point then causes the script to show its usage message and exit.



-- TARGET PLATFORMS --

As of 2018 spring, installs-de-alta project is written to work on Debian and Ubuntu sytems, and Linux distributions which use 'dpkg', 'apt' and 'aptitude' as their package management toolset.  So far work has not been started to adapt this script to alternate package managing tools such as Redhat's 'rpm' or Centos distribution's 'yum'.



-- DEPENDENCY, TOP LEVEL... --

Per the previous section, installs-de-alta.sh depends on the Debian Linux package 'aptitude'.




-- AUTHORS AND CONTRIBUTORS --

*  Ted Havelka   ted@cs.pdx.edu



## --- EOF ---
