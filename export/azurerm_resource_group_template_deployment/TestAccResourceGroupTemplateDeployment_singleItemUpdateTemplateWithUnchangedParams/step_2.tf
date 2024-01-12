
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240112035056398493"
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
  "variables": {
    "forceChangeInTemplate": "forceupdatetemplate"
  },
  "resources": []
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
