#!/usr/bin/env bash

# Bootstraps the Vagrant Box with all we need

# First, some config
VAGRANT_HOME=/home/vagrant
VAGRANT_WORKDIR=/vagrant
VAGRANT_BOOTSTRAP_DIR=$VAGRANT_WORKDIR/vagrant

# Make sure we've got key packages ready
apt update &&
    apt install -y wget openjdk-8-jdk-headless
export JAVA_HOME=$(readlink -f `which javac` | sed "s:/bin/.\+::")

echo *** Installing OpenLDAP ***
source $VAGRANT_BOOTSTRAP_DIR/ldap/provision.sh

echo *** Installing Jetty ***
JETTY_HOME=/opt/jetty
JETTY_DOWNLOAD=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.11.v20180605/jetty-distribution-9.4.11.v20180605.tar.gz
mkdir $JETTY_HOME &&
wget -nv -O- $JETTY_DOWNLOAD | \
    tar --directory $JETTY_HOME --strip-components 1 -xz &&
chown -R root:root $JETTY_HOME

echo *** Installing Shibboleth IDP ***
source $VAGRANT_BOOTSTRAP_DIR/shibboleth/provision.sh