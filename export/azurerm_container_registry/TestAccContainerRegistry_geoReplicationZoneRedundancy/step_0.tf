
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221028171920510528"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr221028171920510528"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                = "West US 2"
    zone_redundancy_enabled = true
  }
}
