

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220712042817460580"
  location = "West Europe"
}


resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-220712042817460580"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_S1"
  capacity            = 1
}
