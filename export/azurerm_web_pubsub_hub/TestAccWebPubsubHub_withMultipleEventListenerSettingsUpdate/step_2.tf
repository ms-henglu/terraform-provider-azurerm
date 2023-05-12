

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230512011427921413"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-230512011427921413"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh230512011427921413"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
