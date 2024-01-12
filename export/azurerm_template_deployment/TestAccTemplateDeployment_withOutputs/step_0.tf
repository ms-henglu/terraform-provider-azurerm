
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035056406113"
  location = "West Europe"
}

output "tfStringOutput" {
  value = azurerm_template_deployment.test.outputs["stringOutput"]
}

output "tfIntOutput" {
  value = azurerm_template_deployment.test.outputs["intOutput"]
}

output "tfFalseOutput" {
  value = azurerm_template_deployment.test.outputs["falseOutput"]
}

output "tfTrueOutput" {
  value = azurerm_template_deployment.test.outputs["trueOutput"]
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-240112035056406113"
  resource_group_name = azurerm_resource_group.test.name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountType": {
      "type": "string",
      "defaultValue": "Standard_LRS",
      "allowedValues": [
        "Standard_LRS",
        "Standard_GRS",
        "Standard_ZRS"
      ],
      "metadata": {
        "description": "Storage Account type"
      }
    },
    "dnsLabelPrefix": {
      "type": "string",
      "metadata": {
        "description": "DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error."
      }
    },
    "intParameter": {
      "type": "int",
      "defaultValue": -123
    },
    "falseParameter": {
      "type": "bool",
      "defaultValue": false
    },
    "trueParameter": {
      "type": "bool",
      "defaultValue": true
    }
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'storage')]",
    "publicIPAddressName": "[concat('myPublicIp', uniquestring(resourceGroup().id))]",
    "publicIPAddressType": "Dynamic",
    "apiVersion": "2015-06-15"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "[variables('apiVersion')]",
      "location": "[variables('location')]",
      "properties": {
        "accountType": "[parameters('storageAccountType')]"
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('apiVersion')]",
      "name": "[variables('publicIPAddressName')]",
      "location": "[variables('location')]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    }
  ],
  "outputs": {
    "stringOutput": {
      "type": "string",
      "value": "[parameters('storageAccountType')]"
    },
    "intOutput": {
      "type": "int",
      "value": "[parameters('intParameter')]"
    },
    "falseOutput": {
      "type": "bool",
      "value": "[parameters('falseParameter')]"
    },
    "trueOutput": {
      "type": "bool",
      "value": "[parameters('trueParameter')]"
    }
  }
}
DEPLOY


  parameters = {
    dnsLabelPrefix     = "terraform-test-240112035056406113"
    storageAccountType = "Standard_GRS"
  }

  deployment_mode = "Incremental"
}
