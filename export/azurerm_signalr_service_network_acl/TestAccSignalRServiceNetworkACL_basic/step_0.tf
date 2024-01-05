

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-signalr-240105064626271140"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctest-signalr-240105064626271140"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}
  

resource "azurerm_signalr_service_network_acl" "test" {
  signalr_service_id = azurerm_signalr_service.test.id
  default_action     = "Deny"

  public_network {
    allowed_request_types = ["ClientConnection"]
  }
}
