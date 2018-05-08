A simple test app for the
[Grails Spring Security SAML Plugin](https://github.com/jeffwils/grails-spring-security-saml) 
with Grails 3.3.3.

Note:

* Although not in the SAML plugin instructions, I've found that I needed to modify
  `init/Application.groovy` inline with what is done in `saml-plugin-test` - i.e. Add
  `@EnableAutoConfiguration(exclude = [SecurityFilterAutoConfiguration])`
* There is no substance to this project, just the bare bones and domain classes for Spring Security.

Steps taken to create:

1. grails create-app samltest
2. Modified build.gradle to add additional repositories and the three additional dependencies
3. ran `./grailsw s2quickstart samltest UserAcct Role`
4. Copied across `conf/security` from other working 3.1.9 project
5. Copied across required config into `conf/application.yml`
6. removed `conf/application.groovy`
7. Modified `init/Application.groovy`

To use:

1. Update `grails-app/conf/security/idp-local.xml` with the metadata for your IDP;
2. Tweak any of the SAML config as required in `grails-app/conf/application.yml`;
3. Launch the app: `./gradlew bootRun`

## TODO

* Update to be a more full fledged test app for the plugin; and
* Add a vagrant setup for provisioning an IDP to test against.
