

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527669594"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest124011994"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-24011994"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "CDC-Canberra"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
	