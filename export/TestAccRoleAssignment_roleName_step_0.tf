
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "d6e3e962-a25f-452d-bd9b-561d48fd3ef7"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id
}
