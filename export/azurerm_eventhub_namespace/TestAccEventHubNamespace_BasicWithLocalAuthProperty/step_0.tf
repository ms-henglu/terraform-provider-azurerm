
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025039079993"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                         = "acctesteventhubnamespace-240119025039079993"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Basic"
  local_authentication_enabled = false
}
