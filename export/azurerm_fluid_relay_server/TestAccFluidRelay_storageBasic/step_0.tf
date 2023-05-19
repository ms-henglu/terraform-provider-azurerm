



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-230519074822422160"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-230519074822422160"
  resource_group_name = azurerm_resource_group.test.name
  location            = "SouthEastAsia"
  storage_sku         = "basic"
  tags = {
    foo = "bar"
  }
}
