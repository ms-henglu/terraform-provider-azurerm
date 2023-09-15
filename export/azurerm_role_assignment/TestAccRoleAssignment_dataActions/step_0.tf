
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "6c0773c6-ab89-4051-a78a-1a738d38127d"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azurerm_client_config.test.object_id
}
