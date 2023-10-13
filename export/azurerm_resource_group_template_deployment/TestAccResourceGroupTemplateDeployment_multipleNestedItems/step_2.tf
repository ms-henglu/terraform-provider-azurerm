
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152773545"
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
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2020-05-01",
      "name": "parent-network",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "10.0.0.0/16"
          ]
        }
      },
      "tags": {
        "Hello": "second"
      },
      "resources": [
        {
          "type": "subnets",
          "apiVersion": "2020-05-01",
          "location": "[resourceGroup().location]",
          "name": "first",
          "dependsOn": [
            "parent-network"
          ],
          "properties": {
            "addressPrefix": "10.0.1.0/24"
          }
        },
        {
          "type": "subnets",
          "apiVersion": "2020-05-01",
          "location": "[resourceGroup().location]",
          "name": "second",
          "dependsOn": [
            "parent-network",
            "first"
          ],
          "properties": {
            "addressPrefix": "10.0.2.0/24"
          }
        }
      ]
    }
  ]
}
TEMPLATE
}
