

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230804030723354145"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-230804030723354145"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh230804030723354145"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
