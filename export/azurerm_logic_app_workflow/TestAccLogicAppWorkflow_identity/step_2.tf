
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230609091534040205"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-user-1ljmz"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Logic App Operator"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230609091534040205"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  depends_on = [azurerm_role_assignment.test]
}
