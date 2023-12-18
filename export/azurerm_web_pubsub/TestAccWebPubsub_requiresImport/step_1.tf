


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-231218072557685987"
  location = "West Europe"
}


resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-231218072557685987"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_S1"
  capacity            = 1
}


resource "azurerm_web_pubsub" "import" {
  name                = azurerm_web_pubsub.test.name
  location            = azurerm_web_pubsub.test.location
  resource_group_name = azurerm_web_pubsub.test.resource_group_name

  sku      = "Standard_S1"
  capacity = 1
}
