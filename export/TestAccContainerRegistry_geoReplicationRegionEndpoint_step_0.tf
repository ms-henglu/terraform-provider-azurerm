
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220415030317277955"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr220415030317277955"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                  = "West US 2"
    regional_endpoint_enabled = true
  }
}
