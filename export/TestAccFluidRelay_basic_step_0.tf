


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-220916011510757183"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-220916011510757183"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    foo = "bar"
  }
}
