
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024120295823"
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
  "parameters": {},
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "2015-06-15",
      "name": "acctestpip-1-230915024120295823",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "tags": {
        "Hello": "first"
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "2015-06-15",
      "name": "acctestpip-2-230915024120295823",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "Dynamic"
      },
      "tags": {
        "Hello": "first"
      }
    }
  ]
}
TEMPLATE
}
