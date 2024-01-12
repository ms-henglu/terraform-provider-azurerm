

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "builtin" {
  name = "Contributor"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-240112224800247605"
  location = "West Europe"
}


resource "azurerm_managed_application_definition" "test" {
  name                = "acctestAppDef240112224800247605"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lock_level          = "ReadOnly"
  display_name        = "UpdatedTestManagedApplicationDefinition"
  description         = "Updated Test Managed Application Definition"
  package_enabled     = true

  create_ui_definition = <<CREATE_UI_DEFINITION
    {
      "$schema": "https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#",
      "handler": "Microsoft.Azure.CreateUIDef",
	  "version": "0.1.2-preview",
	  "parameters": {
         "basics": [
            {}
         ],
         "steps": [
            {
              "name": "storageConfig",
              "label": "Storage settings",
              "subLabel": {
                 "preValidation": "Configure the infrastructure settings",
                 "postValidation": "Done"
              },
              "bladeTitle": "Storage settings",
              "elements": [
                 {
                   "name": "storageAccounts",
                   "type": "Microsoft.Storage.MultiStorageAccountCombo",
                   "label": {
                      "prefix": "Storage account name prefix",
                      "type": "Storage account type"
                   },
                   "defaultValue": {
                      "type": "Standard_LRS"
                   },
                   "constraints": {
                      "allowedTypes": [
                        "Premium_LRS",
                        "Standard_LRS",
                        "Standard_GRS"
                      ]
                   }
                 }
              ]
            }
         ],
         "outputs": {
            "storageAccountNamePrefix": "[steps('storageConfig').storageAccounts.prefix]",
            "storageAccountType": "[steps('storageConfig').storageAccounts.type]",
            "location": "[location()]"
         }
      }
	}
  CREATE_UI_DEFINITION

  main_template = <<MAIN_TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
         "storageAccountNamePrefix": {
            "type": "string"
         },
         "storageAccountType": {
            "type": "string"
         },
         "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]"
         }
      },
      "variables": {
         "storageAccountName": "[concat(parameters('storageAccountNamePrefix'), uniqueString(resourceGroup().id))]"
      },
      "resources": [
         {
           "type": "Microsoft.Storage/storageAccounts",
           "name": "[variables('storageAccountName')]",
           "apiVersion": "2016-01-01",
           "location": "[parameters('location')]",
           "sku": {
              "name": "[parameters('storageAccountType')]"
           },
           "kind": "Storage",
           "properties": {}
         }
      ],
      "outputs": {
         "storageEndpoint": {
           "type": "string",
           "value": "[reference(resourceId('Microsoft.Storage/storageAccounts/', variables('storageAccountName')), '2016-01-01').primaryEndpoints.blob]"
         }
      }
    }
  MAIN_TEMPLATE

  authorization {
    service_principal_id = data.azurerm_client_config.current.object_id
    role_definition_id   = split("/", data.azurerm_role_definition.builtin.id)[length(split("/", data.azurerm_role_definition.builtin.id)) - 1]
  }

  tags = {
    ENV = "Test"
  }
}
