


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-230227175505270152"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-230227175505270152"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    foo = "bar2"
  }
}
