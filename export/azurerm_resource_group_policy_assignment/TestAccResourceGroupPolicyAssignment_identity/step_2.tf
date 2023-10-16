
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest231016034510772765"
  location = "West Europe"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestua231016034510772765"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-231016034510772765"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
