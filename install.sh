#!/bin/bash

base=$(pwd)

if [ "$(pwd)" != "/usr/local/lmf" ]
then
    echo "Soft linking $(pwd) to /usr/local/lmf"
    ln -sf $(pwd) /usr/local/lmf
fi 

echo "Installing needed perl modules"

for module in File::Tail Config::IniFiles
do
    perl -MCPAN -e "install($module)"
done

echo "Installing syslog filter"

#  Don't install twice
perl -n -i -e 'print unless m#/var/log/lmf.log#' /etc/syslog.conf
cat $base/misc/lmf.syslog >> /etc/syslog.conf
touch /var/log/lmf.log
/sbin/service syslog restart

echo "Installing log rotate script for lmf log"
cat $base/misc/lmf.logrotate > /etc/logrotate.d/lmf

echo "Installing startup script"
cat $base/misc/lmf.init > /etc/init.d/lmf
chmod 700 /etc/init.d/lmf
chown root.root /etc/init.d/lmf
/sbin/chkconfig --level 345 lmf on

echo "Setting APPHOME in init script"
perl -p -i -e 's#APPHOME=.*#APPHOME='$base'#;' /etc/init.d/lmf

cat <<EOF
 
Don't forget to start LMF (as root) when you are ready using

/sbin/service lmf start

- thanks for using LMF!

EOF

exit 0
