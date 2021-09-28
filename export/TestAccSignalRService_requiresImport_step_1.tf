

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055924920405"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-210928055924920405"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}


resource "azurerm_signalr_service" "import" {
  name                = azurerm_signalr_service.test.name
  location            = azurerm_signalr_service.test.location
  resource_group_name = azurerm_signalr_service.test.resource_group_name

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}
