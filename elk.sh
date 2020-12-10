#!/bin/bash

sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        sudo apt-get install default-jre -y
    # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            sudo apt-get install openjdk-8-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            sudo yum install default-jre -y
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-1.8.0-openjdk -y
    fi
}

dependency_check_dar() {
java -version
if [ $? -ne 0 ]
    then
        brew update
	brew tap adoptopenjdk/openjdk
	brew cask install adoptopenjdk11
	java -version
    # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            echo "I am installing Java version 11 as you have a version less than 7."
	    brew update
	    brew tap adoptopenjdk/openjdk
	    brew cask install adoptopenjdk11
	    java -version
fi
}


debian_elk() {
    sudo apt-get update
    sudo apt-get install wget
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get update
    sudo apt-get install logstash
    sudo apt-get install elasticsearch
    sudo apt-get install kibana

    # Starting The Services
    sudo service logstash restart
    sudo service elasticsearch restart
    sudo service kibana restart
}

rpm_elk() {
    sudo yum install wget -y
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.rpm
    sudo rpm -ivh /opt/logstash-6.0.0-rc2.rpm
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.rpm
    sudo rpm -ivh /opt/elasticsearch-6.0.0-rc2.rpm
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-linux-x86_64.tar.gz
    sudo tar zxf /opt/kibana-6.0.0-rc2-linux-x86_64.tar.gz -C /opt/
    # Starting The Services
    sudo service logstash start
    sudo service elasticsearch start
    sudo /opt/kibana-6.0.0-rc2-linux-x86_64/bin/kibana &
}

dar_elk() {
    brew update
    brew tap elastic/tap
    brew install elastic/tap/logstash-full
    brew install elastic/tap/elasticsearch-full
    brew install elastic/tap/kibana-full
    export ES_PATH="/usr/local/Cellar/elasticsearch-full/7.10.0/bin"
    export KIBANA_PATH="/usr/local/Cellar/kibana-full/7.10.0/bin"
    export LOGSTASH_PATH="/usr/local/Cellar/logstash-full/7.10.0/bin"
}

# Installing ELK Stack
if [ "$(grep -Ei 'debian|ubuntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_elk
        
        
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_elk
elif ["$(uname | grep arwin)"]
    then
	echo "It's a MacOs/Darwin based system"
	dependency_check_dar
	dar_elk
else
    echo "This script doesn't support ELK installation on this OS."
fi
