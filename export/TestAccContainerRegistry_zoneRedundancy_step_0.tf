
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220811053040682512"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                    = "testacccr220811053040682512"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  sku                     = "Premium"
  zone_redundancy_enabled = true
}
