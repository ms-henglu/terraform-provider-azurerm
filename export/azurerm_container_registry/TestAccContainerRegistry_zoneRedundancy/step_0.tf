
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221124181427197693"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                    = "testacccr221124181427197693"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  sku                     = "Premium"
  zone_redundancy_enabled = true
}
