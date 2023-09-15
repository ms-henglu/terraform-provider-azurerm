

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Contributor"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-230915023723315251"
  location = "West Europe"
}

resource "azurerm_managed_application_definition" "test" {
  name                = "acctestManagedAppDef230915023723315251"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lock_level          = "ReadOnly"
  display_name        = "TestManagedAppDefinition"
  description         = "Test Managed App Definition"
  package_enabled     = true

  create_ui_definition = <<CREATE_UI_DEFINITION
    {
      "$schema": "https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#",
      "handler": "Microsoft.Azure.CreateUIDef",
      "version": "0.1.2-preview",
      "parameters": {
         "basics": [],
         "steps": [],
         "outputs": {}
      }
    }
  CREATE_UI_DEFINITION

  main_template = <<MAIN_TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {

         "stringParameter": {
            "type": "string"
         },
         "secureStringParameter": {
            "type": "secureString"
         }

      },
      "variables": {},
      "resources": [],
      "outputs": {
        "boolOutput": {
          "type": "bool",
          "value": true
        },
        "intOutput": {
          "type": "int",
          "value": 100
        },
        "stringOutput": {
          "type": "string",
          "value": "stringOutputValue"
        },
        "objectOutput": {
          "type": "object",
          "value": {
            "nested_bool": true,
            "nested_array": ["value_1", "value_2"],
            "nested_object": {
              "key_0": 0
            }
          }
        }
      }
    }
  MAIN_TEMPLATE

  authorization {
    service_principal_id = data.azurerm_client_config.test.object_id
    role_definition_id   = split("/", data.azurerm_role_definition.test.id)[length(split("/", data.azurerm_role_definition.test.id)) - 1]
  }
}


resource "azurerm_managed_application" "test" {
  name                        = "acctestManagedApp230915023723315251"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  kind                        = "ServiceCatalog"
  managed_resource_group_name = "infraGroup230915023723315251"
  application_definition_id   = azurerm_managed_application_definition.test.id

  parameter_values = jsonencode({
    stringParameter = {
      value = "value_1_from_parameter_values"
    },
    secureStringParameter = {
      value = ""
    }
  })
}
