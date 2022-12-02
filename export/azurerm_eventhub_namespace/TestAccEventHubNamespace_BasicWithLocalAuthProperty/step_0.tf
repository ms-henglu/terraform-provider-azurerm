
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035705614921"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                         = "acctesteventhubnamespace-221202035705614921"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Basic"
  local_authentication_enabled = false
}
