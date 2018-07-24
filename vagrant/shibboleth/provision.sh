#!/bin/bash

# Expects some env vars are in place due to a calling script sourcing this one.

# ** SHIBBOLETH **
# Download and install Shibboleth IDP
SHIB_INST_DIR=/tmp/shib-inst
SHIB_TARGET_DIR=/opt/shibboleth-idp
cp $VAGRANT_BOOTSTRAP_DIR/shibboleth/idp.properties /tmp/idp.properties &&
mkdir $SHIB_INST_DIR &&
wget -nv -O- https://shibboleth.net/downloads/identity-provider/3.3.3/shibboleth-identity-provider-3.3.3.tar.gz | \
    tar --directory $SHIB_INST_DIR --strip-components 1 -xz &&
    $SHIB_INST_DIR/bin/install.sh \
        -Didp.src.dir=$SHIB_INST_DIR \
        -Didp.target.dir=$SHIB_TARGET_DIR \
        -Didp.host.name=localhost \
        -Didp.scope=localdomain \
        -Didp.merge.properties=/tmp/idp.properties \
        -Didp.sealer.password=abc \
        -Didp.keystore.password=abc &&
    chown -R vagrant:vagrant $SHIB_TARGET_DIR

# We customise the config further so that:
# * our NameID is as wanted, as well as sharing a couple of attributes; and
# * and we read in our SP metadata from a file - which we copy across below.
cp -v $VAGRANT_BOOTSTRAP_DIR/shibboleth/conf/* $SHIB_TARGET_DIR/conf

# We need to fix/tweak the metadata to accommodate the vagrant port forward
SHIB_METADATA_DIR=$SHIB_TARGET_DIR/metadata/
SHIB_METADATA=$SHIB_METADATA_DIR/idp-metadata.xml
sed --in-place \
    -e 's/Location="https:\/\/localhost\/idp/Location="https:\/\/localhost:18443\/idp/g' \
    -e 's/Location="https:\/\/localhost:8443\/idp/Location="https:\/\/localhost:18443\/idp/g' \
    $SHIB_METADATA

# Lastly, let's put in play our SP metadata so it's all ready to simply run.sh
cp $VAGRANT_WORKDIR/grails-app/conf/security/sp-metadata.xml $SHIB_METADATA_DIR/sp.xml

# ** JETTY **
# Setup a Jetty Base
JETTY_BASE=/srv/jettybase-shibboleth-idp
mkdir $JETTY_BASE &&
    cd $JETTY_BASE &&
    java -jar $JETTY_HOME/start.jar \
         --add-to-start=server,ssl,deploy,annotations,resources,console-capture,requestlog,servlets,jsp,jstl,ext,plus,http,https &&
    cd -

# Tweak the ports it's running on
cat >> $JETTY_BASE/start.ini <<STARTINI

# Custom port config from vprov/shibboleth/provision.sh
jetty.http.port=18080
jetty.ssl.port=18443
jetty.httpConfig.securePort=18443
STARTINI

# Create simple jetty run script
JETTY_RUN_SCRIPT=$JETTY_BASE/run.sh
cat >> $JETTY_RUN_SCRIPT <<RUNSH
#!/bin/sh

if [ -z \${JAVA_HOME+x} ]; then
  # Often the case when running as systemd unit
  echo Setting up Java Environment
  export JAVA_HOME=$JAVA_HOME
  PATH=\$JAVA_HOME/bin:\$PATH
fi

cd $JETTY_BASE &&
java -Xmx256m -jar $JETTY_HOME/start.jar &&
cd -
RUNSH
chmod a+x $JETTY_RUN_SCRIPT

# Create context.xml
cat >> $JETTY_BASE/webapps/idp.xml <<CONTEXTXML
<Configure class="org.eclipse.jetty.webapp.WebAppContext">
    <Set name="war">$SHIB_TARGET_DIR/war/idp.war</Set>
    <Set name="contextPath">/idp</Set>
    <Set name="extractWAR">false</Set>
    <Set name="copyWebDir">false</Set>
    <Set name="copyWebInf">true</Set>
</Configure>
CONTEXTXML

# Create an endpoint for the metadata
mkdir $JETTY_BASE/webapps/ROOT &&
    ln -s $SHIB_METADATA $JETTY_BASE/webapps/ROOT/idp-metadata.xml

# Fix file perms so that the vagrant user can run this
chown -R vagrant:vagrant $JETTY_BASE

# Register a systemd unit and start
cat >> /lib/systemd/system/shibboleth.service <<SHIBUNIT
[Unit]
Description=Shibboleth IDP
After=network.target

[Service]
Type=simple
ExecStart=$JETTY_RUN_SCRIPT
User=vagrant

[Install]
WantedBy=multi-user.target
SHIBUNIT
systemctl enable shibboleth && systemctl start shibboleth
