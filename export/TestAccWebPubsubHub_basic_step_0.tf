

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220826003325319424"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-220826003325319424"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh220826003325319424"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
