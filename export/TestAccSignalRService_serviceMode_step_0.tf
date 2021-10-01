
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054211868779"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-211001054211868779"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  features {
    flag  = "ServiceMode"
    value = "Serverless"
  }

  features {
    flag  = "EnableConnectivityLogs"
    value = "False"
  }

  features {
    flag  = "EnableMessagingLogs"
    value = "False"
  }
}
