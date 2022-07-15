
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220715004256774991"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                    = "testacccr220715004256774991"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  sku                     = "Premium"
  zone_redundancy_enabled = true
}
