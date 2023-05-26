
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085129629962"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                          = "acctesteventhubnamespace-230526085129629962"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Basic"
  public_network_access_enabled = false
}
