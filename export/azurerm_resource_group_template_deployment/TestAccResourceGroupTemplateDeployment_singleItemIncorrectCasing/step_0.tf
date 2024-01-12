
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035056393921"
  location = "West Europe"
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Complete"

  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "someParam": {
      "type": "String",
      "allowedValues": [
        "first",
        "second",
        "third"
      ]
    }
  },
  "variables": {},
  "resources": [
    {
      "type": "microsoft.insights/actionGroups",
      "apiVersion": "2019-06-01",
      "name": "acctestTemplateDeployAG-240112035056393921",
      "location": "Global",
      "dependsOn": [],
      "tags": {},
      "properties": {
        "groupShortName": "rick-c137",
        "enabled": true,
        "emailReceivers": [
          {
            "name": "Rick Sanchez",
            "emailAddress": "rick@example.com"
          }
        ],
        "smsReceivers": [],
        "webhookReceivers": []
      }
    }
  ]
}
TEMPLATE

  parameters_content = <<PARAM
{
  "someParam": {
   "value": "first"
  }
}
PARAM
}
