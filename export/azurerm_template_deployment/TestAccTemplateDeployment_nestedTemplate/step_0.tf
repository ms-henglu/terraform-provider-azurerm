
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022750530625"
  location = "West Europe"
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-240119022750530625"
  resource_group_name = azurerm_resource_group.test.name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "resourceGroupName": "[resourceGroup().name]"
  },
  "resources": [
    {
      "apiVersion": "2017-05-10",
      "name": "nested-template-deployment",
      "type": "Microsoft.Resources/deployments",
      "resourceGroup": "[variables('resourceGroupName')]",
      "properties": {
        "mode": "Incremental",
        "template": {
          "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
          "contentVersion": "1.0.0.0",
          "variables": {
            "location": "[variables('location')]",
            "resourceGroupName": "[variables('resourceGroupName')]"
          },
          "resources": [
            {
              "type": "Microsoft.Network/publicIPAddresses",
              "apiVersion": "2015-06-15",
              "name": "acctest-pip",
              "location": "[variables('location')]",
              "properties": {
                "publicIPAllocationMethod": "Dynamic"
              }
            }
          ]
        }
      }
    }
  ]
}
DEPLOY


  deployment_mode = "Complete"
}
