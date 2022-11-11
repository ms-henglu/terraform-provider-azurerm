
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014301730457"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-221111014301730457"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 2
  }
}
