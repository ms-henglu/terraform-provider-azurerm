
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221021033929407368"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr221021033929407368"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                = "West US 2"
    zone_redundancy_enabled = true
  }
}
