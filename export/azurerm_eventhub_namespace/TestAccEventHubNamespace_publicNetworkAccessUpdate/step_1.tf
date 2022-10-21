
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034126628863"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                          = "acctesteventhubnamespace-221021034126628863"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Basic"
  public_network_access_enabled = false
}
