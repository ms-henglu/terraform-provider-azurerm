
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 230106034851118017"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-pa-7s6da"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestua7s6da"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-7s6da"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = "West Europe"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
