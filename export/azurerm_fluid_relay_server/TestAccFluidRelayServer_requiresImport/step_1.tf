




provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fluidrelay-240119025052203850"
  location = "West Europe"
}


resource "azurerm_fluid_relay_server" "test" {
  name                = "acctestRG-fuildRelayServer-240119025052203850"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    foo = "bar"
  }
}


resource "azurerm_fluid_relay_server" "import" {
  name                = azurerm_fluid_relay_server.test.name
  resource_group_name = azurerm_fluid_relay_server.test.resource_group_name
  location            = azurerm_fluid_relay_server.test.location
}
