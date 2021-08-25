

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test" {
  name                 = "d424bf58-63ff-4bcc-ad8d-ab0c7a4bdead"
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id
}


resource "azurerm_role_assignment" "import" {
  name                 = azurerm_role_assignment.test.name
  scope                = azurerm_role_assignment.test.scope
  role_definition_name = azurerm_role_assignment.test.role_definition_name
  principal_id         = azurerm_role_assignment.test.principal_id
}
