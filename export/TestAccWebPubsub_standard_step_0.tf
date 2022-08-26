

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220826003325324489"
  location = "West Europe"
}


resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-220826003325324489"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku      = "Standard_S1"
  capacity = 1
}
