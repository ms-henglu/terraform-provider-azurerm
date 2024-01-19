
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728760822"
  location = "West Europe"
}

output "test" {
  value = azurerm_template_deployment.test.outputs["testOutput"]
}

resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-240119025728760822"
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
    }
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "storageAccountName": "badStorageAccountNameTooLong",
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
    }
  ],
  "outputs": {
    "testOutput": {
      "type": "string",
      "value": "Output Value"
    }
  }
}
DEPLOY


  parameters = {
    storageAccountType = "Standard_GRS"
  }

  deployment_mode = "Complete"
}
