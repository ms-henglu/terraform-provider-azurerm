



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-221021034133765391"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-221021034133765391"
  resource_group_name = azurerm_resource_group.test.name
  location            = "SouthEastAsia"
  storage_sku         = "basic"
  tags = {
    foo = "bar"
  }
}
