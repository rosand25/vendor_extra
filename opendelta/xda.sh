#!/bin/bash

my_rc_file=~/.xdarc

#my_account1="AFH FTP Login"
#my_account2="BB FTP Login"
my_account3="XDA Forum Login"

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

cd xda

read -p "AFH Download Link:" afhdl
    if [ -n "$afhdl" ] ; then echo -e "Link=$afhdl | cut -d '=' -f 2" ; else afhdl="none"; fi
afhurl=`echo $afhdl | cut -d '=' -f 2`

sed -i 's/XDAFILE/'$XDAFILE'/g' op.txt
sed -i 's/AFHFILE/'$afhurl'/g' op.txt
#nano op.txt
python update_op.py -u $my_login3 -p $my_passw3 -v 7
#cat op.txt
sed -i 's/'$XDAFILE'/XDAFILE/g' op.txt
sed -i 's/'$afhurl'/AFHFILE/g' op.txt

sed -i 's/XDAFILE/'$XDAFILE'/g' post.txt
sed -i 's/AFHFILE/'$afhurl'/g' post.txt
nano post.txt
python update_post.py -u $my_login3 -p $my_passw3 -v 7
cat post.txt
sed -i 's/'$XDAFILE'/XDAFILE/g' post.txt
sed -i 's/'$afhurl'/AFHFILE/g' post.txt
cd ..
