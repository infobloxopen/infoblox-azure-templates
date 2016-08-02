#!/bin/bash
# Test creates Vms using templates.
# All is done in resource group, which is created at begining and removed at the end.
# Check steps are next:
# 1. Creates VM with all new elements.
# 2. Attaches VM to existing objects, created on step 1 and with existing Public Ip
# 3. Attaches VM to existing objects, created on step 1, but with no Public Ip.
# Script doesn't raise any errors and doesn't check, if objects are actually created.
# It starts deployment using templates, with different input (all templates to be used).
# Supposed to be usefull to validate templates after they are changed.
# Note: To check the templates, they must be uploaded to some public place. In this example it is github.
# Don't forget to change TEMPLATE_URI and templateBaseUrl in mainTemplate.json according to the place where templates are uploaded.

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