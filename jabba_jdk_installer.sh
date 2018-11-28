#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -e "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


# jabba & JDK
## Install jabba
colorEcho ${BLUE} "Installing jabba..."
curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && \
    . ~/.jabba/jabba.sh

## OpenJDK
colorEcho ${BLUE} "Installing JDK 11..."
# apt install -y default-jdk default-jre
# jabba install openjdk@1.11.0-1 && jabba alias default openjdk@1.11.0-1
jabba install 1.11.0-1 && jabba alias default 1.11.0-1

## Oracle jdk 8
## http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# colorEcho ${BLUE} "Installing Oracle JDK 8..."
# mkdir -p /usr/lib/jvm && cd /usr/lib/jvm && \
#     wget --no-check-certificate --no-cookies \
#         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#         http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz && \
#     tar -zxvf jdk-8u181-linux-x64.tar.gz && \
#     ln -s /usr/lib/jvm/jdk1.8.0_181/ /usr/lib/jvm/oracle-jdk8 && \
#     rm -f jdk-8u181-linux-x64.tar.gz && cd $HOME

## Oracle jdk 11
## https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html
# colorEcho ${BLUE} "Installing Oracle JDK 11..."
# mkdir -p /usr/lib/jvm && cd /usr/lib/jvm && \
#     wget --no-check-certificate --no-cookies \
#         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#         http://download.oracle.com/otn-pub/java/jdk/11+28/55eed80b163941c8885ad9298e6d786a/jdk-11_linux-x64_bin.tar.gz && \
#     tar -zxvf jdk-11_linux-x64_bin.tar.gz && \
#     ln -s /usr/lib/jvm/jdk-11/ /usr/lib/jvm/oracle-jdk11 && \
#     rm -f jdk-11_linux-x64_bin.tar.gz && cd $HOME

# ## Install new JDK alternatives
# update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle-jdk11/bin/java 100
# update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle-jdk11/bin/javac 100
# update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle-jdk8/bin/java 200
# update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle-jdk8/bin/javac 200

# ## Remove the existing alternatives
# # update-alternatives --remove java /usr/lib/jvm/oracle-jdk11/bin/java
# # update-alternatives --remove javac /usr/lib/jvm/oracle-jdk11/bin/javac
# # update-alternatives --remove java /usr/lib/jvm/oracle-jdk8/bin/java
# # update-alternatives --remove javac /usr/lib/jvm/oracle-jdk8/bin/javac

# ## Change the default Java versions using the update-alternatives system:
# # update-alternatives --config java
# # update-alternatives --config javac

if [[ -x "$(command -v java)" ]]; then
    export JAVA_HOME=$(readlink -f $(which java) | sed "s:/jre/bin/java::" | sed "s:/bin/java::")
    export JRE_HOME=$JAVA_HOME/jre
    export CLASSPATH=$JAVA_HOME/lib
    export PATH=$PATH:$JAVA_HOME/bin
fi
