#!/bin/bash
# This script requires Azure CLI at least 2.0.8
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
# If you are using not the master brunch, You need to change according to the place where templates are uploaded:
# baseUrl in parameters files and AZURE_TEMPLATE_URI in this test script.
AZURE_TEMPLATE_PATH="./main/mainTemplate.json"

# To avoid overlapping with other developers please change PREFIX in test script. Also you should
# modify parameter files accordingly.
# You can quickly do the job by running this command from the current directory:
# find . -type f -exec sed -i 's/former_prefix/new_prefix/g' {} +
PREFIX="templtest"

RESOURCE_GROUP="${PREFIX}group"
LOCATION="eastus"
DEPLOYMENT_NAME="${PREFIX}deployment$(date +%Y%m%d%H%M%S)"

PARAMETERS_DIR="utils/params"

RESPONSE=$(az group show --name ${RESOURCE_GROUP})
if [ ${RESPONSE} ] ; then
    echo "Resource group ${RESOURCE_GROUP} exists.
To avoid overlapping with other developers please change PREFIX in test script.
Also you should modify parameter files accordingly.
You can quickly do the job by running this command from the current directory:
find . -type f -exec sed -i 's/former_prefix/new_prefix/g' {} +"
    exit 1
fi

az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

echo "-------------------"
echo "Test creation of all new elements"
az group deployment create \
      --template-file "${AZURE_TEMPLATE_PATH}" \
      --parameters @"${PARAMETERS_DIR}/parameters.allnew.json" \
      --resource-group "${RESOURCE_GROUP}" \
      --name "${DEPLOYMENT_NAME}"

echo "-------------------"
echo "Test adding one more VM to existing elements"
# Add Public Ip, will be used as existing.
az network public-ip create \
      --name "${PREFIX}pipexisting" \
      --allocation-method Dynamic \
      --dns-name "${PREFIX}pipexisting" \
      --resource-group "${RESOURCE_GROUP}" \
      --location "${LOCATION}"

# Add VM
az group deployment create \
      --template-file "${AZURE_TEMPLATE_PATH}" \
      --parameters @"${PARAMETERS_DIR}/parameters.existing.json" \
      --resource-group "${RESOURCE_GROUP}" \
      --name "${DEPLOYMENT_NAME}"

echo "-------------------"
echo "Test adding one more VM to existing elements with no Public Ip and no availiability set"
az group deployment create \
      --template-file "${AZURE_TEMPLATE_PATH}" \
      --parameters @"${PARAMETERS_DIR}/parameters.none.json" \
      --resource-group "${RESOURCE_GROUP}" \
      --name "${DEPLOYMENT_NAME}"

# Remove resource group
az group delete --name "${RESOURCE_GROUP}" --yes
