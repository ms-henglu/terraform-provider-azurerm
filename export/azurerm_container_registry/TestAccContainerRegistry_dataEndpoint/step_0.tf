
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230505050128775732"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr230505050128775732"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = "false"
}
