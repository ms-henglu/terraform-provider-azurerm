
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211001020621428792"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr211001020621428792"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                = "West US 2"
    zone_redundancy_enabled = true
  }
}
