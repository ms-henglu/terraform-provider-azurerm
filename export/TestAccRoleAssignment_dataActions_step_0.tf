
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "16e5d56f-547c-47d1-a43b-e6056e9effed"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azurerm_client_config.test.object_id
}
