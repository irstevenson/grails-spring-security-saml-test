#!/bin/bash

# Expects some env vars are in place due to a calling script sourcing this one.

LDAP_PROV_DIR=$VAGRANT_BOOTSTRAP_DIR/ldap

# *** Setup an LDAP server with a few accounts ***
# - first, we need to set some answers to the slapd debconf (so that we can skip the interactive
# install)
# - then install the bits
# - now add the users
debconf-set-selections $LDAP_PROV_DIR/slapd-options.debconf && \
    apt -y install slapd ldap-utils && \
    slapadd -c -v -l $LDAP_PROV_DIR/ldap-setup.ldif

