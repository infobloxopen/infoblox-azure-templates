#!/bin/bash

RESOURCE_GROUP="templtestgroup"
LOCATION="eastus"
DEPLOYMENT_NAME="newdeployment$(date +%Y%m%d%H%M%S)"

TEMPLATE_URI="https://raw.githubusercontent.com/ibekleiner/infoblox-azure-templates/master/debug/mainTemplate.json"
PARAMETERS_DIR="."

azure group create "${RESOURCE_GROUP}" "${LOCATION}"


echo "Test creation of all new elements"
azure group deployment create \
    --template-uri "${TEMPLATE_URI}" \
    --parameters-file "${PARAMETERS_DIR}/parameters.allnew.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"


echo "Test adding one more VM to existing elements"
# Add Public Ip, will be used as existing.
azure network public-ip create \
    --name "templatestestpipexisting" \
    --allocation-method Dynamic \
    --domain-name-label "templatestestpipexisting" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}"

# Add VM
azure group deployment create \
    --template-uri "${TEMPLATE_URI}"\
    --parameters-file "${PARAMETERS_DIR}/parameters.existing.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"


echo "Test adding one more VM to existing elements with no Publuc Ip"
azure group deployment create \
    --template-uri "${TEMPLATE_URI}"\
    --parameters-file "${PARAMETERS_DIR}/parameters.nopip.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"

azure group delete --quiet "${RESOURCE_GROUP}"