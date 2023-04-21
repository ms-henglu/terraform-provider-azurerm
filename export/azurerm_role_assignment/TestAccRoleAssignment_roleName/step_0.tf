
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "0061c024-7252-409c-8d1c-81af7d34e17d"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id
}
