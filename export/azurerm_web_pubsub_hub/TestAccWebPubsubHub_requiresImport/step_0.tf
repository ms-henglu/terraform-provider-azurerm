

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-221111014301738123"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-221111014301738123"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh221111014301738123"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
