
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033436821309"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230227033436821309"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }
  tags = {
    ENV = "test"
  }
}
