





provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-230113181137385567"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestRG-userAssignedIdentity-230113181137385567"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-230113181137385567"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
  tags = {
    foo = "bar"
  }
}
