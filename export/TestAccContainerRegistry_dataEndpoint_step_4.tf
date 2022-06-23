
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220623223212822222"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr220623223212822222"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = "false"
}
