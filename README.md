A simple test app for the
[Grails Spring Security SAML Plugin](https://github.com/jeffwils/grails-spring-security-saml) 
with Grails 3.3.3.

Note:

* Although not in the SAML plugin instructions, I've found that I needed to modify
  `init/Application.groovy` inline with what is done in `saml-plugin-test` - i.e. Add
  `@EnableAutoConfiguration(exclude = [SecurityFilterAutoConfiguration])`
* There is no substance to this project, just the bare bones and domain classes for Spring Security.

## Usage

This repo also contains a Vagrant box that will provide a ready to run SAML IDP (Shibboleth IDP)
and the application is configured to use it. So to get up and running real quick all you need
do is:

0. Install JDK and Vagrant (and Virtualbox)
1. `vagrant up`
2. `./gradlew bootRun`
3. Then go to http://localhost:8080/ in your browser where you'll be redirected to login via
   Shibboleth. Enter `test-admin` and password `abc` and you'll be all nicely logged in. (Note:
   seeing this is just a test setup, you'll need to accept various security warnings about
   self signed certs and transitions from https to http.)

## How was this created

Following are the details here on how this app was created, for those who might be creating a
new app themselves.

1. grails create-app samltest
2. Modified build.gradle to add additional repositories and the three additional dependencies
3. ran `./grailsw s2quickstart samltest UserAcct Role`
4. Copied across `conf/security` from other working 3.1.9 project
5. Copied across required config into `conf/application.yml`
6. removed `conf/application.groovy`
7. Modified `init/Application.groovy`

Since that initial creation though, much work has been done on `conf/security` and
`conf/application.yml` so I'd recommend you probably start now with the files here.

## Key / Certificate Generation

The keys and certificate were generated with the following:

<pre>
keytool -genkeypair -dname "CN=Grails Spring Security SAML Test"
        -alias test -keypass password
        -keystore keystore.jks
        -storepass password -validity 3650 -keyalg RSA
</pre>

Then to get the certificate to place in `sp.xml` I did:

    keytool -list -keystore keystore.jks -alias test -rfc
    
And copy and pasted the Base64 of the certificate.

## TODO

* Update to be a more full fledged test app for the plugin; and
* Work at having `master` use the current released version of the plugin, and `develop` use
  a snapshot version - usually built from the current state of the plugin's `develop` branch.
