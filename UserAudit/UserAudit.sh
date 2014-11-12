#!/bin/sh
######################################################################
# This Script is to Audit systems for the following on current Users:
# 1. Last Login
# 2. Last Password Change
# 3. Account Status
#
# This script is meant to be run by "Rover", and reports are emailed
# to the appropriate managers.
#
# It is the design of this script not to be platform dependent.
#    ----"One script to rule them ALL"
#####################################################################
############ Changelog ##############################################
#####################################################################
## -- Script written by Dave Davis
##
#####################################################################

###############
## Variables ##
###############

HOST=`hostname`

# Date Variables
DATE=`date +%Y%m%d`
DATE2=`date +"%r %a %d %h %Y"`
DATE3=`date +'%h %Y'`
TIME=`date +%H:%M`
TODAY=`date +%s`
LPEXP=45
EXPDAYS=90
EXPIRY=$(( $EXPDAYS*86400 ))
DIR=/admin/GRC
GREP=/usr/bin/grep
FGREP=/usr/xpg4/bin/grep
USERS=/tmp/CleanUsers.list
OS=`uname -a|awk '{print $1}'`

# List Variables
TMPLIST=/tmp/tempusers.list
CLNLIST=/tmp/CleanUsers.list


##################
### FUNCTIONS! ###
##################

## Linux ##

lin_CleanUsers () {
     #statements
     cat /etc/passwd | awk -F: '{print $1}' > $TMPLIST
     cat $TMPLIST | grep -vf /tmp/AllVendor.list | grep -vf /tmp/AllService.list | grep -vf /tmp/LinSys.list > $CLNLIST
}

lin_UserAudit () {
     #statements
     for i in `cat $CLNLIST`;
     do
             #Variables
               nolog=`lastlog -u $i |grep $i | awk '{print $2}'`
               umnt=`lastlog -u $i | grep $i|awk '{ print $5 }'`
              uday=`lastlog -u $i | grep $i|awk '{ print $6 }'`
             ltime=`lastlog -u $i | grep $i|awk '{ print $7 }'`
             year=`lastlog -u $i | grep $i|awk '{ print $9 }'`
               llogin=`date +%s -d "$umnt $uday $year $ltime"`
               lpass=`grep $i /etc/shadow | cut -d: -f3`
               lpassepoch=$(( $lpass * 86400 ))
               lpassdif=$(( $TODAY - $lpassepoch ))
               lpassdays=$(( $lpassdif/86400 ))
               login=$(( $TODAY - $llogin ))
               llogdays=$(( $login/86400 ))
                # Last Log In Over 90 Days Ago, or Never Logged In.
             if [ $nolog = "**Never" ] && [[ $lpassdays -gt $LPEXP ]]; then
               echo "###################################"
               echo "`cat /etc/passwd | grep $i | awk -F: '{print $5}'`"
               echo "###################################"
             echo "Username: $i"
               echo "--NEVER LOGGED IN--"
               echo "Last Password Change: $lpassdays days ago."
               echo
                elif [[ $lpassdays -gt $LPEXP ]] && [[ $llogdays -gt $EXPDAYS ]]; then
               echo "###################################"
               echo "`cat /etc/passwd | grep $i | awk -F: '{print $5}'`"
               echo "###################################"
            echo "Username: $i"
                echo "Last Logged In: $llogdays days ago."
               echo "Last Password Change: $lpassdays days ago."
               echo
            fi
     done
}


## AIX ##

aix_CleanUsers () {
     #statements
     cat /etc/passwd | awk -F: '{print $1}' > $TMPLIST
     cat $TMPLIST | grep -vf /admin/GRC/AllVendor.list | grep -vf /admin/GRC/AllService.list | grep -vf /admin/GRC/AIXSys.list > $CLNLIST
}

aix_UserAudit () {
     #statements
     for i in `cat $CLNLIST`;
     do
             #Variables
               llogin=`lsuser -a time_last_login $i | awk '{print $2}'|awk -F= '{print $2}'`
               lpass=`pwdadm -q $i | grep lastupdate | awk {'print $3'}`
               lpassdif=$(( $TODAY-$lpass ))
               lpassdays=$(( $lpassdif / 86400 ))
               login=$(( ( $TODAY - $llogin ) / 86400 ))
               # Last Log In Over 90 Days Ago, or Never Logged In.
             if [[ $llogin = "" ]]; then
                    if [[ $lpassdays -gt $LPEXP ]]; then
                    echo "###################################"
                    echo "`cat /etc/passwd | grep $i | awk -F: '{print $5}'`"
                    echo "###################################"
                   echo "Username: $i"
                     echo "--NEVER LOGGED IN--"
                    echo "Last Password Change: $lpassdays days ago."
                    echo
                    fi
             else
                    mini=$(( $TODAY - $llogin ))
                 if  [[ $lpassdays -gt $LPEXP ]] && [[ $mini -gt $EXPIRY ]]; then
                         echo "###################################"
                         echo "`cat /etc/passwd | grep $i | awk -F: '{print $5}'`"
                         echo "###################################"
                     echo "Username: $i"
                         echo "Last Logged In: $login days ago."
                         echo "Last Password Change: $lpassdays days ago."
                         echo

                 fi
             fi
     done

}


########################
## GENERATE USERLISTS ##
########################

if [ "$OS" = "Linux" ]; then
               lin_CleanUsers
             elif  [ "$OS" = "AIX" ]; then
                 aix_CleanUsers
             fi

##########################
## GENERATE USER REPORT ##
##########################
if [ $OS = "Linux" ]; then
     lin_CleanUsers
     lin_UserAudit
     elif  [ $OS = "AIX" ]; then
          aix_CleanUsers
         aix_UserAudit
         elif  [ $OS = "SunOS" ]; then
               sol_UserAudits
             fi

##############
## CLEAN UP ##
##############

rm -f $TMPLIST
rm -f $CLNLIST