#!/bin/sh

log="harden_ubuntu.log"
ssh_port=22

#install Uncomplicated FireWall
echo -e "installing ufw \t\t `date` ..\n" >> $log
apt-get install ufw

#allow ssh and http
echo -n "allowing ssh and http \t\t `date` ..\n" >> $log
ufw allow ssh
ufw allow http
ufw allow 7908
ufw allow http
#enable ufw and check status
echo -e "enabling ufw and checking the status \t\t `date`..\n" >> $log
ufw --force enable
ufw status verbose

#secure shared memory
grep shm /etc/fstab 2>&1 > /dev/null
if [ $? -eq 1 ]; then
	echo -e "adding shared memory configuration to /etc/fstab \t\t `date`\n" >> $log
	echo "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab
fi

#restrict users from su to root except for users in group admin
groupadd admin
usermod -a -G admin sahmed
dpkg-statoverride --update --add root admin 4750 /bin/su

#change the ssh port number to 55
echo -e "Changing ssh port to $ssh_port \t\t `date` ..\n" >> $log
sed -ie "s/Port 22/Port ${ssh_port}/" /etc/ssh/sshd_config

#deny root login
echo -e "Deny root ssh login \t\t `date` ..\n" >> $log
sed -ie 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

#prevent password based login/only key based login will be enabled
sed -ie "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -ie "s/PubkeyAuthentication no/PubkeyAuthentication yes/" /etc/ssh/sshd_config

#Remove the banner
grep DebianBanner  /etc/ssh/sshd_config 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
	echo -e "Removing banner \t\t `date` ..\n" >> $log
	echo "DebianBanner no" >> /etc/ssh/sshd_config
fi

#restart the ssh services
echo -e "Restarting ssh \t\t `date` ..\n" >> $log
service ssh restart

#Prevent source routing of incoming packets and log malformed IP's enter the following in a terminal window:


echo -e "Modifying sysctl \t\t `date` ..\n" >> $log
# IP Spoofing protection
grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.all.rp_filter\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
	echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.default.rp_filter\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.all.accept_source_route\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.all.accept_source_route = 0 >> /etc/sysctl.conf
fi


grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv6.conf.all.accept_source_route\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv6.conf.all.accept_source_route = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.default.accept_source_route\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.default.accept_source_route = 0 >> /etc/sysctl.conf
fi


grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv6.conf.default.accept_source_route\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv6.conf.default.accept_source_route = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.all.send_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.all.send_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.default.send_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.default.send_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.tcp_syncookies\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.tcp_syncookies = 1 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.tcp_max_syn_backlog\s*=\s*2048" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.tcp_max_syn_backlog = 2048 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.tcp_synack_retries\s*=\s*2" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.tcp_synack_retries = 2 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.tcp_syn_retries\s*=\s*5" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.tcp_syn_retries = 5 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.all.log_martians\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.all.log_martians = 1 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.icmp_ignore_bogus_error_responses\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.icmp_ignore_bogus_error_responses = 1 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.all.accept_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.all.accept_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv6.conf.all.accept_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv6.conf.all.accept_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.conf.default.accept_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.conf.default.accept_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv6.conf.default.accept_redirects\s*=\s*0" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv6.conf.default.accept_redirects = 0 >> /etc/sysctl.conf
fi

grep -v "#" /etc/sysctl.conf | grep "\s*net.ipv4.icmp_echo_ignore_all\s*=\s*1" 2>&1 >> /dev/null
if [ $? -eq 1 ]; then
        echo net.ipv4.icmp_echo_ignore_all = 1 >> /etc/sysctl.conf
fi

sysctl -p
