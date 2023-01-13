
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c89d9e4c-8de4-45e8-bc70-d41d1eed81fb"
  name               = "acctestrd-230113180728724715"
  scope              = data.azurerm_subscription.primary.id
  description        = "Created by the Role Assignment Acceptance Test"

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "test" {
  name               = "868f95ca-1822-4b58-9f95-37717f10596e"
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.test.role_definition_resource_id
  principal_id       = data.azurerm_client_config.test.object_id
}
