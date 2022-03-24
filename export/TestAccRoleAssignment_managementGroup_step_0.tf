
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Monitoring Reader"
}

resource "azurerm_management_group" "test" {
  group_id = "5ec6844e-f448-47f6-9846-45f1eb256821"
}

resource "azurerm_role_assignment" "test" {
  scope              = azurerm_management_group.test.id
  role_definition_id = data.azurerm_role_definition.test.id
  principal_id       = data.azurerm_client_config.test.object_id
}
