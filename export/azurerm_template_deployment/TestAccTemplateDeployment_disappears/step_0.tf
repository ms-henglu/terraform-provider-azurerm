
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035234765714"
  location = "West Europe"
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-221222035234765714"
  resource_group_name = azurerm_resource_group.test.name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "variables": {
    "location": "[resourceGroup().location]",
    "publicIPAddressType": "Dynamic",
    "apiVersion": "2015-06-15",
    "dnsLabelPrefix": "[concat('terraform-tdacctest', uniquestring(resourceGroup().id))]"
  },
  "resources": [
     {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('apiVersion')]",
      "name": "acctestpip-221222035234765714",
      "location": "[variables('location')]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[variables('dnsLabelPrefix')]"
        }
      }
    }
  ]
}
DEPLOY


  deployment_mode = "Complete"
}
