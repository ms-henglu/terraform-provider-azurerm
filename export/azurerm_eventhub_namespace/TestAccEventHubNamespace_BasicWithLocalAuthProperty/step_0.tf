
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091326058309"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                         = "acctesteventhubnamespace-230609091326058309"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Basic"
  local_authentication_enabled = false
}
