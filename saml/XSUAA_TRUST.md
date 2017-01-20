#HowTo for SAML/JWT trust

You can create trust between XSUAA and HANA database with the bash script ( https://github.com/strehle/xsuaa-scripts/blob/master/saml/xsuaa_hdbtrust.sh ) yourself. You need to know following parameters:

```
system user (of logical database)
system password (of logical database)
xsa admin user (is optional. if you provide a name this user is enabled for logon with SAML)
in case of MDC the database name
```

The bash script can be executed from a remote machine. The machine needs only XS runtime, e.g. xs command line tool. The script can be executed with an extra settings file or you modify the script and uncomment the variables. 

##Example for local usage with single database instance

Call the script under the OS system admmin user of your XSA installation, e.g. hxeadm if system is HXE.
In this case you execute the script without a setting file and any change, because the password is requested in call and all settings are taken from environment. 

##Example for multi database containers (MDC)

In case of MDC there is a SYSTEMDB and a MDC with database name of your choice.
```
   HANA_SID=XSA
   HANA_INSTANCE=00
   HANA_SYSTEM_USER=system
   MDC_DATABASE=ABC
   XSA_USER=xsa_admin
```
Save this to file xsuaa_settings.cfg

Execute the shell script xsuaa_hdbtrust.sh. 
```
   ./xsuaa_hdbtrust.sh xsuaa_settings.cfg
```
The script creates the trust and executes the test. Typical successful output is:
```
{"SESSION_USER":"SYSTEM","CURRENT_USER":"SYSTEM","SESSION_CONTEXT('XS_APPLICATIONUSER')":"XSA_ADMIN"}
```
In case of an error you should look into uaa.log for the error reason. Typical error is, that system user password is not correct.

##Example file for HANA Express

HANA Express is a free developer edition of SAP HANA. 
http://www.sap.com/developer/how-tos/2016/09/hxe-howto-tutorialprep.html
This installation is by default a multi database containers (MDC) installation. You can create own databases, see
https://blogs.sap.com/2016/10/27/create-tenant-database-sap-hana-express-sap-hana-academy/

However if you use XSA and you run your applications into one of these new databases there is no trust between XSUAA and this new database in HANA. You can create this trust with following settings.
```
HANA_SID=HXE
HANA_INSTANCE=90
HANA_XSPATH=/hana/shared/HXE/xs
HANA_SYSTEM_USER=system
XSA_USER=xsa_admin
MDC_DATABASE=TESTDB
```
