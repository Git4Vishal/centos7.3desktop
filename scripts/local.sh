SETTING UP A LOCAL ENVIRONMENT

A. Setting up a virtualbox to run centos 7 image:
1. Download and install virtualbox.
https://www.virtualbox.org/wiki/Downloads

2. Download and install vagrant software.
https://www.vagrantup.com/downloads.html

Windows host has to be restarted after the install.

3. Open a command prompt. Create a directory "Vagrant" under C:\Users\UserName\ directory and change directory to it.
> mkdir Vagrant
> cd Vagrant

4. Execute the following command on a cmd terminal.
> vagrant init esss/centos-7.1-desktop

> vagrant init bento/centos-7.1

This command creates a file with name "Vagrantfile" in the directory.
Edit the Vagrantfile to setup Private Network, Memory, CPUs, Hostname, etc.
Save the Vagrantfile.

Add the following lines after - config.vm.box = "bento/centos-7.1"
  config.vm.provider "virtualbox" do |vb|
    # Set the name seen in Virtualbox GUI
    vb.name = "Centos 7.1"
    # Set video memory
    vb.customize ["modifyvm", :id, "--vram", "64"] 
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end  
  config.vm.define :node1 do |a1|
    a1.vm.hostname = "node1.example.com"
    a1.vm.network :private_network, ip: "192.168.0.11"
    a1.vm.provider :virtualbox do |vb|
      vb.memory = "8192"
    end
  end

5. Execute the following command to bring up the virtual machine.
> vagrant up

6. Login to the machine
root/vagrant
or
vagrant/vagrant

7. Install desktop
yum groupinstall "X Window System"
yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts
unlink /etc/systemd/system/default.target
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
yum groupinstall "Development Tools"
yum install kernel-devel
reboot

#### Use these steps only if root and vagrant users password is not vagrant.
This command takes sometime to complete as the virtual machine image is acquired and provisioned.
root and vagrant users are created when the image is provisioned.
The password should be vagrant but if it is not then use the following procedure to reset the root password:
- Reboot the virtual machine
- During boot GRUB menu is highlighted. Select your boot image from boot grub menu and press E to edit
- Find the line starting with "linux16" and change ro with rw init=/sysroot/bin/sh
- Now press Control+x to start on single user mode
- Access the system with the following command: 
  chroot /sysroot
- Type in "passwd root"
- Set your root password
- Type in "passwd vagrant"
- Set your vagrant password
- Update selinux information
  touch /.autorelabel
- Exit chroot
  exit
- Reboot your system
  reboot
  ############

B. Setting up Kafka on the centos 7 virtual machine:
1. Login into the centos 7 virtual machine.

2. Execute the following steps:
# Setting required packages
sudo yum update -y 
sudo yum install -y telnet
sudo yum install -y net-tools
sudo yum install -y ntp
sudo yum install -y curl
sudo yum install -y wget
sudo yum install -y firefox

sudo chkconfig ntpd on
sudo /etc/init.d/ntpd start
sudo chkconfig iptables off
sudo /etc/init.d/iptables stop
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
sudo sh -c 'echo "* soft nofile 10000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* hard nofile 10000" >> /etc/security/limits.conf'
sudo sh -c 'echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag'
sudo sh -c 'echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled'

# Setting timezone
sudo ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
sudo systemctl start ntpd

# Install Oracle Java JDK 8
# cd /opt/jdk1.8.0_111/
# alternatives --install /usr/bin/java java /opt/jdk1.8.0_111/bin/java 2
# alternatives --config java
# alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_111/bin/jar 2
# alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_111/bin/javac 2
# alternatives --set jar /opt/jdk1.8.0_111/bin/jar
# alternatives --set javac /opt/jdk1.8.0_111/bin/javac

sudo mkdir -p /opt/java && cd /opt/java
sudo wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz && sudo tar xvf jdk-8u111-linux-x64.tar.gz
sudo ln -s /opt/java/jdk1.8.0_111 current
sudo echo 'JAVA_HOME=/opt/java/current' > /etc/profile.d/java.sh
sudo echo 'export JAVA_HOME' >> /etc/profile.d/java.sh
sudo echo 'JDK_HOME=$JAVA_HOME' >> /etc/profile.d/java.sh 
sudo echo 'export JDK_HOME' >> /etc/profile.d/java.sh
sudo echo 'PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
sudo echo 'export PATH' >> /etc/profile.d/java.sh

# Install Scala 2.11.X
# sudo mkdir -pf /usr/local/scala && cd /usr/local/scala
# sudo wget http://www.scala-lang.org/files/archive/scala-2.11.8.tgz && sudo tar xvfz scala-2.11.8.tgz
# sudo update-alternatives --install /usr/bin/scala scala /usr/local/scala/scala-2.11.8/bin/scala 1 --slave /usr/bin/scalac scalac /usr/local/scala/scala-2.11.8/bin/scalac --slave /usr/bin/scalap scalap /usr/local/scala/scala-2.11.8/bin/scalap --slave /usr/bin/scaladoc scaladoc /usr/local/scala/scala-2.11.8/bin/scaladoc --slave /usr/bin/fsc fsc /usr/local/scala/scala-2.11.8/bin/fsc

sudo mkdir -p /opt/scala && cd /opt/scala
sudo wget http://www.scala-lang.org/files/archive/scala-2.11.8.tgz && sudo tar xvfz scala-2.11.8.tgz
sudo ln -s /opt/scala/scala-2.11.8 current
sudo update-alternatives --install /usr/bin/scala scala /opt/scala/current/bin/scala 1 --slave /usr/bin/scalac scalac /opt/scala/current/bin/scalac --slave /usr/bin/scalap scalap /opt/scala/current/bin/scalap --slave /usr/bin/scaladoc scaladoc /opt/scala/current/bin/scaladoc --slave /usr/bin/fsc fsc /opt/scala/current/bin/fsc
sudo echo 'SCALA_HOME=$(readlink -f /usr/bin/scala | sed "s:/bin/scala::")' > /etc/profile.d/scala.sh
sudo echo 'export SCALA_HOME' >> /etc/profile.d/scala.sh

# Install Kafka - This installation has to match the Scala version installed
sudo mkdir -p /opt/kafka && cd /opt/kafka
sudo wget "http://apache.cs.utah.edu/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz" && sudo tar xvfz kafka_2.11-0.10.1.0.tgz
sudo ln -s /opt/kafka/kafka_2.11-0.10.1.0 current
sudo echo 'KAFKA_HOME=/opt/kafka/current' > /etc/profile.d/kafka.sh
sudo echo 'PATH=$KAFKA_HOME/bin:$PATH' >> /etc/profile.d/kafka.sh
sudo echo 'export PATH' >> /etc/profile.d/kafka.sh
# 1. Start Zookeeper
# 2. Start Kafka-Server
# 3. Create a Kafka Topic
# 4. Configure and Start Kafka Producer
# 5. Configure and start Kafka Consumer
#nohup kafka-server-start.sh $KAFKA_HOME/config/server.properties > $KAFKA_HOME/kafka.log 2>&1 &

# Install mysql database
sudo cd /opt
sudo wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum update -y
sudo yum install -y mysql-server
sudo systemctl start mysqld
sudo mysqladmin -u root password 'NantHealth'

mysql --user=root --password=NantHealth
CREATE DATABASE retaildb;
GRANT ALL on retaildb.* to 'retaildba'@'%' identified by 'NantHealth';
GRANT ALL on retaildb.* to 'retaildba'@'localhost' identified by 'NantHealth';
GRANT ALL on retaildb.* to 'retaildba'@'node1.example.com' identified by 'NantHealth';
FLUSH PRIVILEGES;
QUIT

sudo mkdir -p /opt/git && cd /opt/git
sudo git clone https://github.com/dgadiraju/code
mysql --user=retaildba --password=NantHealth
use retaildb;
source /opt/git/code/hadoop/edw/database/retail_db.sql
QUIT

# SELECT CONCAT("SHOW GRANTS FOR '",user,"'@'",host,"';") FROM mysql.user;
# SHOW GRANTS FOR 'retaildba'@'localhost';

# Install Maxwell Connector = MYSQL + KAFKA
sudo mkdir -p /opt/maxwell && cd /opt/maxwell
sudo wget "https://github.com/zendesk/maxwell/releases/download/v1.4.2/maxwell-1.4.2.tar.gz" && sudo tar zxvf maxwell-1.4.2.tar.gz
sudo wget "https://github.com/zendesk/maxwell/releases/download/v1.7.0/maxwell-1.7.0.tar.gz" && sudo tar zxvf maxwell-1.7.0.tar.gz
sudo ln -s /opt/maxwell/maxwell-1.4.2 current
sudo echo '' >> /etc/my.cnf 
sudo echo '[mysqld]' >> /etc/my.cnf 
sudo echo 'server-id=1' >> /etc/my.cnf 
sudo echo 'log-bin=master' >> /etc/my.cnf 
sudo echo 'binlog_format=row' >> /etc/my.cnf 
sudo service mysqld restart
sudo echo 'MAXWELL_HOME=/opt/maxwell/current' > /etc/profile.d/maxwell.sh
sudo echo 'PATH=$MAXWELL_HOME/bin:$PATH' >> /etc/profile.d/maxwell.sh
sudo echo 'export PATH' >> /etc/profile.d/maxwell.sh

# Connect to the MySQL server and provision Maxwell user.
mysql --user=root --password=NantHealth
GRANT ALL on maxwell.* to 'maxwell'@'%' identified by 'NantHealth';
GRANT ALL on maxwell.* to 'maxwell'@'localhost' identified by 'NantHealth';
GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'%';
GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'localhost';
FLUSH PRIVILEGES;
QUIT

bin/maxwell --user='maxwell' --password='XXXXXX' --host='127.0.0.1' --producer=stdout

bin/maxwell --user='maxwell' --password='XXXXXX' --host='127.0.0.1' \
   --producer=kafka --kafka.bootstrap.servers=localhost:9092


# create user 'testuser'@'localhost' identified by 'password';
# grant all on testdb.* to 'testuser' identified by 'password';

Setup HDP using Ambari:
1. As a root user, install the repo.
[root@node1 ~]# wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.4.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
2017-01-17 15:24:49 URL:http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.4.2.0/ambari.repo [287/287] -> "/etc/yum.repos.d/ambari.repo" [1]
[root@node1 ~]# cat /etc/yum.repos.d/ambari.repo
#VERSION_NUMBER=2.4.2.0-136

[Updates-ambari-2.4.2.0]
name=ambari-2.4.2.0 - Updates
baseurl=http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.4.2.0
gpgcheck=1
gpgkey=http://public-repo-1.hortonworks.com/ambari/centos7/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1


2. Install ambari-server package
[root@node1 ~]# yum -y install ambari-server
Loaded plugins: fastestmirror
...
...
...
...
Installed:
  ambari-server.x86_64 0:2.4.2.0-136                                                                                                                                                                               

Dependency Installed:
  postgresql.x86_64 0:9.2.18-1.el7                                  postgresql-libs.x86_64 0:9.2.18-1.el7                                  postgresql-server.x86_64 0:9.2.18-1.el7                                 

Complete!

3. Setup ambari server with Java home pointing to custom location (Location of Java installation)

[root@node1 ~]# ambari-server setup -s --java-home=/opt/java/current/jre/
Using python  /usr/bin/python
Setup ambari-server
Checking SELinux...
SELinux status is 'disabled'
Customize user account for ambari-server daemon [y/n] (n)? 
Adjusting ambari-server permissions and ownership...
Checking firewall status...
Checking JDK...
WARNING: JAVA_HOME /opt/java/current/jre/ must be valid on ALL hosts
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Completing setup...
Configuring database...
Enter advanced database configuration [y/n] (n)? 
Configuring database...
Default properties detected. Using built-in database.
Configuring ambari database...
Checking PostgreSQL...
Running initdb: This may take up to a minute.
Initializing database ... OK


About to start PostgreSQL
Configuring local database...
Connecting to local database...done.
Configuring PostgreSQL...
Restarting PostgreSQL
Extracting system views...
ambari-admin-2.4.2.0.136.jar
............
Adjusting ambari-server permissions and ownership...
Ambari Server 'setup' completed successfully.

4. Start ambari server
[root@node1 ~]# ambari-server start
Using python  /usr/bin/python
Starting ambari-server
Ambari Server running with administrator privileges.
Organizing resource files at /var/lib/ambari-server/resources...
Ambari database consistency check started...
No errors were found.
Ambari database consistency check finished
Server PID at: /var/run/ambari-server/ambari-server.pid
Server out at: /var/log/ambari-server/ambari-server.out
Server log at: /var/log/ambari-server/ambari-server.log
Waiting for server start....................
Ambari Server 'start' completed successfully.

5. Install ambari agent
[root@node1 ~]# yum -y install ambari-agent
Loaded plugins: fastestmirror
...
...
...
...
Installed:
  ambari-agent.x86_64 0:2.4.2.0-136                                                                                                                                                                                

Complete!

6. Configured /etc/hosts with network information
[root@node1 conf]# cat /etc/hosts
127.0.0.1 node1.example.com node1
192.168.0.11    node1.example.com       node1
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

7. replace localhost with node1.example.com in /etc/ambari-agent/conf/ambari-agent.ini

8. Start ambari agent
[root@node1 conf]# ambari-agent start
Verifying Python version compatibility...
Using python  /usr/bin/python
Checking for previously running Ambari Agent...
Starting ambari-agent
Verifying ambari-agent process status...
Ambari Agent successfully started
Agent PID at: /run/ambari-agent/ambari-agent.pid
Agent out at: /var/log/ambari-agent/ambari-agent.out
Agent log at: /var/log/ambari-agent/ambari-agent.log





