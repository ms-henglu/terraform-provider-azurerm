
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "323b85e2-cdce-45b0-95f5-ccc7cfdb6e11"
  name               = "acctestrd-211013071533242661"
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
  name               = "31e864b0-f2db-4a64-ab6a-6aa7bc95e018"
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.test.role_definition_resource_id
  principal_id       = data.azurerm_client_config.test.object_id
}
