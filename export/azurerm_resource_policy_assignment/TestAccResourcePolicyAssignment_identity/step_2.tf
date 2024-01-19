
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest240119025606755495"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240119025606755495"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestua240119025606755495"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-240119025606755495"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
