



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-230804025956329512"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-230804025956329512"
  resource_group_name = azurerm_resource_group.test.name
  location            = "SouthEastAsia"
  storage_sku         = "basic"
  tags = {
    foo = "bar"
  }
}
