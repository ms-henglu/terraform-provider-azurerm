
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211210034504739099"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                    = "testacccr211210034504739099"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  sku                     = "Premium"
  zone_redundancy_enabled = true
}
