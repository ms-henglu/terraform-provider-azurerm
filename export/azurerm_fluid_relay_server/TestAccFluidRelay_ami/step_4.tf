





provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-221202035717129592"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestRG-userAssignedIdentity-221202035717129592"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-221202035717129592"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    foo = "bar"
  }
}
