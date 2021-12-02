#!/bin/bash

if ! command -v oc &> /dev/null; then
    echo "oc could not be found." && echo "Please refer to https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html"
    exit
fi

isloggedIn=`oc whoami &> /dev/null`
if [ $? -ne 0 ]; then
    echo "oc is not logged in" && echo "Please refer to https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands"
    exit
fi

if ! command -v python &> /dev/null; then
    echo "oc is not logged in" && echo "Please refer to https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands"
    exit
fi

set -a; . .env; set +a; green='\033[0;32m'; clear='\033[0m'

echo -e "${green}> [ STEP 0 OUT 5 ]: Prepare CRs definitions .. ${clear}"
for t in models/*py; do python $t; done
echo ">> Done .."

echo -e "${green}> [ STEP 1 OUT 5 ]: Creating new Project/Namespace ..${clear}"
oc new-project $namespace &> /dev/null  && sleep 30
echo  ">> Done .."

echo -e "${green}> [ STEP 2 OUT 5 ]: Adding IBM Operator Catalog ..${clear}"
oc apply -f definitions/ibm-operator-catalog.yml &> /dev/null  && sleep 30
echo ">> Done .."

echo -e "${green}> [ STEP 3 OUT 5 ]: Adding ImagePull secret ..${clear}"
oc create secret docker-registry ibm-entitlement-key --from-file=.dockerconfigjson=definitions/auth-config.json -n $namespace  &> /dev/null  && sleep 30
echo ">> Done .."

echo -e "${green}> [ STEP 4 OUT 5 ]: Create IBM Cloud Pak for Integration subscriptions ..${clear}"
oc apply -f definitions/operator-group.yml -n $namespace &> /dev/null  && sleep 30
oc apply -f definitions/operator-subscription.yml -n $namespace &> /dev/null && sleep 300
while [[ $(oc get pods -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo ">>> waiting for pods to be Ready" && sleep 30; done
echo ">> Done .."

echo -e "${green}> [ STEP 5 OUT 5 ]: Deploy the Platform Navigator - it will take ~45-min..${clear}"
oc apply -f definitions/platform-navigator.yml -n $namespace &> /dev/null && sleep 60
while [[ $(oc get PlatformNavigator/integration-pn-mvp -o 'jsonpath={..status.conditions[].type}') != *"Ready"* ]]; do echo ">>> waiting for PlatformNavigator to be Ready" && sleep 300; done
echo ">> Done .."

echo ">> Platform Navigator access credentials .." && echo "# console_url";
oc get PlatformNavigator integration-pn-mvp -o jsonpath='{.status.endpoints[].uri}' -n $namespace; echo ""
oc extract secret/platform-auth-idp-credentials -n ibm-common-services --to=- 