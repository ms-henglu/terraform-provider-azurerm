

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220527034727283718"
  location = "West Europe"
}


resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-220527034727283718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_S1"
  capacity            = 1
}
