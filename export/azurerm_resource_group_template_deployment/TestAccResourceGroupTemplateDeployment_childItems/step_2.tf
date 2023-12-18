
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072455225979"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt231218072455225979"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Incremental"

  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Network/routeTables/routes",
      "apiVersion": "2020-06-01",
      "name": "${azurerm_route_table.test.name}/child-route",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressPrefix": "10.2.0.0/16",
        "nextHopType": "none"
      }
    }
  ]
}
TEMPLATE
}
