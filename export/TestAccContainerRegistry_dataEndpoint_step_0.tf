
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211210034504733570"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                  = "testacccr211210034504733570"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  sku                   = "Premium"
  data_endpoint_enabled = "false"
}
