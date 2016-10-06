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
# You need to set  baseUrl in parameters file according to the place where templates are uploaded.
# Also you need to set AZURE_TEMPLATE_URI, e.g. you can add this line to your shell init file:
# export AZURE_TEMPLATE_URI="https://raw.githubusercontent.com/ibekleiner/infoblox-azure-templates/master/main/mainTemplate.json"
# Also please set AZURE_DEV_ID to avoid conflicts with developers running tests simultaneously:
# export AZURE_DEV_ID="dk"

RESOURCE_GROUP="${AZURE_DEV_ID}templtestgroup"
LOCATION="eastus"
DEPLOYMENT_NAME="${AZURE_DEV_ID}newdeployment$(date +%Y%m%d%H%M%S)"

PARAMETERS_DIR="utils/params"

azure group create "${RESOURCE_GROUP}" "${LOCATION}"

echo "-------------------"
echo "Test creation of all new elements"
azure group deployment create \
    --template-uri "${AZURE_TEMPLATE_URI}" \
    --parameters-file "${PARAMETERS_DIR}/parameters.allnew.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"


echo "-------------------"
echo "Test adding one more VM to existing elements"
# Add Public Ip, will be used as existing.
azure network public-ip create \
    --name "${AZURE_DEV_ID}templatestestpipexisting" \
    --allocation-method Dynamic \
    --domain-name-label "${AZURE_DEV_ID}templatestestpipexisting" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}"

# Add VM
azure group deployment create \
    --template-uri "${AZURE_TEMPLATE_URI}"\
    --parameters-file "${PARAMETERS_DIR}/parameters.existing.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"

echo "-------------------"
echo "Test adding one more VM to existing elements with no Publuc Ip and no availiability set"
azure group deployment create \
    --template-uri "${AZURE_TEMPLATE_URI}"\
    --parameters-file "${PARAMETERS_DIR}/parameters.none.json" \
    --resource-group "${RESOURCE_GROUP}" \
    "${DEPLOYMENT_NAME}"

# Remove resource group
azure group delete --quiet "${RESOURCE_GROUP}"
