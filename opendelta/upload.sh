#!/bin/bash

# Script to generate delta files for OpenDelta - by Jorrit 'Chainfire' Jongma

# Get device either from $DEVICE set by calling script, or first parameter

if [ "$DEVICE" == "" ]; then
    if [ "$1" != "" ]; then
        DEVICE=$1
    fi
fi

if [ "$DEVICE" == "" ]; then
    echo "Abort: no device set" >&2
    exit 1
fi

# ------ CONFIGURATION ------

HOME=$(pwd)

SERVER1="ftp://uploads.androidfilehost.com"
SERVER2="ftp.basketbuild.com"
FILEMASK="omni-"
FILE_MATCH="omni-*.zip"
PATH_DELTA="$HOME/publish/delta/$DEVICE"
PATH_FULL="$HOME/publish/full/$DEVICE"
PATH_LAST="$HOME/last/$DEVICE"
FTP_DIR_DELTA="OmniROM/.delta/$DEVICE/"
FTP_DIR_FULL="OmniROM/$DEVICE/"
#VERBOSE="-v"
upload="true"

my_rc_file=~/.xdarc
my_account1="AFH FTP Login"
my_account2="BB FTP Login"
#my_account3="XDA Forum Login"


if [ ! -f ${my_rc_file} ]; then touch ${my_rc_file}; chmod 600 ${my_rc_file}; else source ${my_rc_file}; fi

if [ -n "$my_account1" ] ; then
    if [[ ! -n "$my_login1" || ! -n "$my_passw1" ]] ; then
        echo -e "$my_account1"
        read -p "Username:" my_login1
        read -p "Password:" my_passw1
            if [ -n "$my_login1" ] && [ -n "$my_passw1" ] ; then echo -e "my_login1=$my_login1\nmy_passw1=$my_passw1" >> ${my_rc_file} ; echo "USERDATA written to ${my_rc_file}"; else echo "ERROR. no data written!"; fi
    fi
fi
if [ -n "$my_account2" ] ; then
    if [[ ! -n "$my_login2" || ! -n "$my_passw2" ]] ; then
        echo -e "$my_account2"
        read -p "Username:" my_login2
        read -p "Password:" my_passw2
            if [ -n "$my_login2" ] && [ -n "$my_passw2" ] ; then echo -e "my_login2=$my_login2\nmy_passw2=$my_passw2" >> ${my_rc_file} ; echo "USERDATA written to ${my_rc_file}"; else echo "ERROR. no data written!"; fi
    fi
fi
if [ -n "$my_account3" ] ; then
    if [[ ! -n "$my_login3" || ! -n "$my_passw3" ]] ; then
    echo -e "\e[1;38;5;81m"$my_account3"\e[0m"
    read -p "Username:" my_login3
    read -p "Password:" my_passw3
        if [ -n "$my_login3" ] && [ -n "$my_login3" ] ; then echo -e "my_login3=$my_login3\nmy_passw3=$my_passw3" >> ${my_rc_file} ; echo "USERDATA written to ${my_rc_file}"; else echo "ERROR. no data written!"; fi
    fi
fi

# ------ PROCESS ------

getFileName() {
    echo ${1##*/}
}

getFileNameNoExt() {
    echo ${1%.*}
}

FILE_DELTA_DELTA=$(getFileName $(ls -1 $PATH_DELTA/*.delta))
FILE_DELTA_SIGN=$(getFileName $(ls -1 $PATH_DELTA/*.sign))
FILE_DELTA_UPDATE=$(getFileName $(ls -1 $PATH_DELTA/*.update))

FILE_FULL_MD5SUM=$(getFileName $(ls -1 $PATH_FULL/*.md5sum))
FILE_FULL_ZIP=$(getFileName $(ls -1 $PATH_FULL/*.zip))
FILE_FULL_LOG=$(getFileNameNoExt $(ls -1 $PATH_FULL/*.zip))

mv $PATH_FULL/omni*-Changelog.txt $FILE_FULL_LOG.txt

FILE_LAST=$(getFileName $(ls -1 $PATH_LAST/$FILE_MATCH))

if [[ "$upload" == "true" ]] ; then
echo -e "\n"
echo -n "UPLOADING $FILE_DELTA_DELTA to $SERVER2 "
if curl $VERBOSE -T $PATH_DELTA/$FILE_DELTA_DELTA -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_DELTA &> /dev/null; then echo -n "SUCCESS"; rm $PATH_DELTA/$FILE_DELTA_DELTA; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_DELTA_SIGN to $SERVER2 "
if curl $VERBOSE -T $PATH_DELTA/$FILE_DELTA_SIGN -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_DELTA &> /dev/null; then echo -n "SUCCESS"; rm $PATH_DELTA/$FILE_DELTA_SIGN; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_DELTA_UPDATE to $SERVER2 "
if curl $VERBOSE -T $PATH_DELTA/$FILE_DELTA_UPDATE -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_DELTA &> /dev/null; then echo -n "SUCCESS"; rm $PATH_DELTA/$FILE_DELTA_UPDATE; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_FULL_MD5SUM to $SERVER2 "
if curl $VERBOSE -T $PATH_FULL/$FILE_FULL_MD5SUM -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_FULL &> /dev/null; then echo -n "SUCCESS"; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_FULL_ZIP to $SERVER2 "
if curl $VERBOSE -T $PATH_FULL/$FILE_FULL_ZIP -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_FULL &> /dev/null; then echo -n "SUCCESS"; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_FULL_LOG to $SERVER2 "
if curl $VERBOSE -T $PATH_FULL/$FILE_FULL_LOG -u $my_login2:$my_passw2 $SERVER2/$FTP_DIR_FULL &> /dev/null; then echo -n "SUCCESS"; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_FULL_MD5SUM to $SERVER1 "
if curl $VERBOSE -T $PATH_FULL/$FILE_FULL_MD5SUM -u $my_login1:$my_passw1 $SERVER1/ &> /dev/null; then echo -n "SUCCESS"; rm $PATH_FULL/$FILE_FULL_MD5SUM; else echo -n "FAILED"; fi
echo -e "\n"
echo -n "UPLOADING $FILE_FULL_ZIP to $SERVER1 "
if curl $VERBOSE -T $PATH_FULL/$FILE_FULL_ZIP -u $my_login1:$my_passw1 $SERVER1/ &> /dev/null; then echo -n "SUCCESS"; rm $PATH_FULL/$FILE_FULL_ZIP; else echo -n "FAILED"; fi
echo -e "\n"
fi

XDAFILE="$FILE_FULL_ZIP"
export XDAFILE

LASTFILE="$FILE_LAST"

lfyrs=`echo $LASTFILE|cut -d '-' -f 3|cut -b 1-4`
lfmon=`echo $LASTFILE|cut -d '-' -f 3|cut -b 5-6`
lfday=`echo $LASTFILE|cut -d '-' -f 3|cut -b 7-8`
lastdate=$lfyrs-$lfmon-$lfday
lastdate2="2017-03-10"


#cd ..; cd ..; cd ..
#/home/sub77/bin/gitcomp-plain --since=2017-03-01 -10
# since "$lastdate" 
#> /tmp/changelog
#cd $HOME

exit 0
