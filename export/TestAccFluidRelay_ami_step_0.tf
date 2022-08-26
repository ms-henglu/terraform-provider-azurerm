


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-220826002747282662"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-220826002747282662"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    foo = "bar"
  }
}
