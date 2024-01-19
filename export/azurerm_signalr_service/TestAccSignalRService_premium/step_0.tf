
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025830585814"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-240119025830585814"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Premium_P1"
    capacity = 1
  }
}
