
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220114014030989158"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr220114014030989158"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                  = "West US 2"
    regional_endpoint_enabled = true
  }
}
