# XSUAA
What is XSUAA from SAP?
See http://help.sap.com/saphelp_hanaplatform/helpdata/en/cc/45f1833e364d348b5057a60d0b8aed/frameset.htm

# xsuaa-scripts
This repository contains some admin scripts for XSUAA. They are mainly for the enhancements which were added on top of the UAA from CloudFoundry. 

## XSA users
The XSUAA uses HANA as datasource for its user store. The identities in XSA are propagated with SAML2 (prio to HANA 2) and with JWT (supported in HANA 2 SP1). This identity propagation is possible, if there is a trust between HANA DB process and XSUAA. This trust is created during installation time. However there are certain situations (key change of HANA secure store for example) why this trust can
break. The trust can be created via REST call to XSUAA. In folder /saml you will find a bash script to create this trust.


