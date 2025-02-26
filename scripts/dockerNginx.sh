#!/bin/bash
# BEWARE: Use 1 for installation and 0 for no installation
setenforce 0
sed -i s/enforcing/disabled/g /etc/selinux/config
cat /etc/selinux/config
read -p "Enter 0 or 1 nginx" nginxs
read -p "Enter 0 or 1 docker" dock
read -p "move docker installation to /app dir? 0 or 1" move_docker
if [[ $nginxs == 1 ]]; then
    echo "Installing Nginx More"
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
    yum install https://repo.aerisnetwork.com/pub/aeris-release-8.rpm -y
    yum install nginx-more -y
    systemctl start nginx
    systemctl enable nginx
fi
if [[ $dock == 1 ]]; then
    # disable firewalld
    fd_status=$(systemctl is-active --quiet firewalld)
    if [[ $fd_status != 0 ]]; then systemctl stop firewalld && systemctl disable firewalld; else echo "" >/dev/null; fi

    echo -e '\n Installing Docker'
    yum remove container* podman* -y # remove docker conflicting packaages
    yum install yum-utils -y
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo -y
    yum install docker-ce docker-ce-cli containerd.io -y
    systemctl start docker
    systemctl enable docker
fi

if [[ $move_docker == 1 ]]; then
    echo -e '\n Moving docker installation folder to /app dir'
    systemctl stop docker

    # check if rsync is installed or not
    check_rsync=$(yum list installed rsync)
    if [[ $? == 1 ]]; then yum install rsync -y; else echo "" >/dev/null; fi

    rsync -avhp /var/lib/docker /app/docker
    mv /var/lib/docker /var/lib/docker.old
    file=/etc/docker/daemon.json
    rm -rf ${file}

    cat << EOF >> ${file}
    {
        "data-root": "/app/docker"
    }
EOF
    systemctl restart docker
fi

