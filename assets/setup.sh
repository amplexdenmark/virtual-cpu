#!/bin/bash

echo "SETUP"

set -o errexit

cd /assets

mkdir -p /opt/
ln -sf /amplex/virtcpu /opt/virtcpu
useradd --base-dir /opt --groups adm,tty,dialout,sudo,dip,plugdev amplex

echo 'amplex:changeme' | chpasswd
chsh -s /bin/bash amplex
sed -i '/^amplex:/d' /etc/shadow
cat >> /etc/shadow << 'EOF'
amplex:$6$TustsMiH$tRPEQEjEp3adUvf6DQigXpXjY7prOxGE/.WjGjvrNSTGwCRlFbu51N8sUj5e75hYHh0G5f7qfZ/1tBNFsFsx61:15491:0:99999:7:::
EOF
mkdir ~amplex
chown amplex:amplex ~amplex
mkdir -p /amplex
chown amplex:amplex /amplex
chmod g+w /amplex
ln -s /opt/amplex /home/amplex

sudo -u amplex sh -c 'cd ~amplex; pwd; cp -a /assets/amplex /opt; umask 077; mkdir .ssh; cat > .ssh/authorized_keys' << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCHj/KQY0uBpAfjLdq1OiGUAGo/uZY1QLeX3vpfpMF/gB4cFqc9/3/TXXyGYH46XocdAN+najktAq8b79495cvSPcSInYxS2dmMjwDTfCw98Azn42FuDfFlG9/lpeH80AqHFrTLyWYzmdqXOmwxvL+YylP87CTeBVxX/tbbdQ/fWwiu2u2kKXuiBjuo/NTU/sOjPlkSEttK7jRsyJhySe3Oq0/jYEt+MJMOCITdbf/SxKAquyc5ewMEbY4Q3N4j/d1vmsw6OdKchfDz9QnIVTQg+nACX9hJ2WKy/vluwQFFIfl+TPHttaBBH1QjPjru6hjvhgXcamQIIehuPThwgi4f ec2-logon-access
EOF


sudo -u amplex bash -s << 'EOF'
    cd ~amplex

    ln -s /amplex/home/bin .
    ln -s /amplex/home/tmp .
    ln -s /amplex/home/.bash_history .
    ln -s /amplex/home/bashrc.d .
    ln -s /amplex/home/.config .
    mkdir -p /amplex/home/tmp
EOF

# Install startup script for container 
cp /assets/startup.sh /sbin/startup.sh
chmod 755 /sbin/startup.sh
cp /assets/cpu-start.sh /sbin/cpu-start.sh
chmod 755 /sbin/cpu-start.sh

echo $WSPASSWD > /opt/amplex/.wspasswd

