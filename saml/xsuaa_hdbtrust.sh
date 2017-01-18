#!/bin/bash
# This script calls XSUAA rest endpoint /sap/rest/samltrust/test
# to create trust and /sap/rest/samltrust/test to check 
# if XS_APPLICATIONUSER can be set
# (c) 2017 SAP SE
echo "Print out XS_APPLICATIONUSER: Starting."
echo ""
if [ "$#" -ge 1 ]; then
  echo "Configuration:" $1
  source $1
else
  echo "Parameter Warning. You SHOULD specify the configuration, e.g. \"./xsuaa_hdbtrust.sh xsuaa_settings.cfg\"."
fi
echo ""
if [ $? != 0 ]; then
  echo "Test UAA Trust to HANA. Use defaults."
  HANA_SID=$SAPSYSTEMNAME
  HANA_INSTANCE=$TINSTANCE
  HANA_XSPATH=$XSPATH
else
  echo "XS_APPLICATIONUSER: external configuration loaded successfully."
fi
if [ -z "$HANA_SID" ]; then
  HANA_SID=XSA
fi
if [ -z "$HANA_INSTANCE" ]; then
  HANA_INSTANCE=00
fi
if [ -z "$HANA_XSPATH" ]; then
  HANA_XSPATH=/usr/sap/hana/shared/$HANA_SID/xs
fi
if [ -z "$XSA_UAA_ENDPOINT" ]; then
  XSA_UAA_ENDPOINT="https://`hostname -f`:3${HANA_INSTANCE}32/uaa-security"
fi
if [ -z "$JDBC_HANA_ENDPOINT" ]; then
  JDBC_HANA_ENDPOINT="jdbc:sap://`hostname -f`:3${HANA_INSTANCE}15"
fi
if [ -z "$HANA_SYSTEM_USER" ]; then
  HANA_SYSTEM_USER="SYSTEM"
fi
if [ -z "$XSA_USER" ]; then
  XSA_USER="XSA_ADMIN"
fi
if [ -z "$HANA_SYSTEM_PASSWORD" ]; then
  read -s -p "Enter Password: " HANA_SYSTEM_PASSWORD
fi
echo ""
echo "HANA_SID=$HANA_SID"
echo "HANA_INSTANCE=$HANA_INSTANCE"
echo "HANA_XSPATH=$HANA_XSPATH"
echo "UAA_ENDPOINT=$XSA_UAA_ENDPOINT"
echo "HANA jdbcURL=$JDBC_HANA_ENDPOINT"
echo "HANA USER=$HANA_SYSTEM_USER"
echo "XSA ADMIN=$XSA_USER"

XS_OAUTH_TOKEN=`$HANA_XSPATH/bin/xs oauth-token |grep bearer`
#XS_OAUTH_TOKEN_PLAIN=`$HANA_XSPATH/bin/xs oauth-token |grep bearer | sed 's/bearer //g'`
if [ "$XS_OAUTH_TOKEN" = "" ]; then
  XS_TARGET="https://`hostname -f`:3${HANA_INSTANCE}30"
  echo "Error, oauth token cannot be retrieved, perform xs login first on $XS_TARGET with user $XSA_USER"
  $HANA_XSPATH/bin/xs login -u $XSA_USER -a $XS_TARGET --skip-ssl-validation
  XS_OAUTH_TOKEN=`$HANA_XSPATH/bin/xs oauth-token |grep bearer`
  if [ "$XS_OAUTH_TOKEN" = "" ]; then
    exit 1
  fi
fi
echo "Create Trust and call $XSA_UAA_ENDPOINT/sap/rest/samltrust/add"
curl -k -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: $XS_OAUTH_TOKEN" "$XSA_UAA_ENDPOINT/sap/rest/samltrust/add" -d "{\"user\":\"${HANA_SYSTEM_USER}\",\"password\":\"${HANA_SYSTEM_PASSWORD}\",\"xsaAdmin\":\"${XSA_USER}\",\"jdbcUrl\":\"${JDBC_HANA_ENDPOINT}\"}"
echo ""
echo "Check Trust and call $XSA_UAA_ENDPOINT/sap/rest/samltrust/test"
echo "Result: "
curl -k -X GET -H "Accept: application/json" -H "Authorization: $XS_OAUTH_TOKEN" "$XSA_UAA_ENDPOINT/sap/rest/samltrust/test" 
echo ""
