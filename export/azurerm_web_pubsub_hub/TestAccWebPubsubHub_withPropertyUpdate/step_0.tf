

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-240119025830596101"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-240119025830596101"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh240119025830596101"
  web_pubsub_id = azurerm_web_pubsub.test.id
}
