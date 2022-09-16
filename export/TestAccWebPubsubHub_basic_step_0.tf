

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220916012044480699"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-220916012044480699"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh220916012044480699"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
