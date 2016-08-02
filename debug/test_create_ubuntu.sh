#!/bin/bash
# Test creates Ubuntu using templates.
# All is done in resource group, which is created at begining and removed at the end.
# Don't forget to remove plan from vm-availabilityset-none.json


RESOURCE_GROUP="templtestgroupubuntu"
LOCATION="eastus"
DEPLOYMENT_NAME="newdeployment$(date +%Y%m%d%H%M%S)"

TEMPLATE_URI="https://raw.githubusercontent.com/ibekleiner/infoblox-azure-templates/master/debug/mainTemplate.json"
PARAMETERS_DIR="."

azure group create "${RESOURCE_GROUP}" "${LOCATION}"

echo "-------------------"
echo "Test creation of all new elements"
azure group deployment create \
    --template-uri "${TEMPLATE_URI}" \
    --parameters-file "${PARAMETERS_DIR}/parameters.ubuntu.allnew.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"

# Remove resource group
azure group delete --quiet "${RESOURCE_GROUP}"