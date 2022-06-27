
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220627130944193573"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr220627130944193573"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                = "West US 2"
    zone_redundancy_enabled = true
  }
}
