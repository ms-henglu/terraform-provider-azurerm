
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230421021917799159"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                    = "testacccr230421021917799159"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  sku                     = "Premium"
  zone_redundancy_enabled = true
}
