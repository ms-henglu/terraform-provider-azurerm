
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211112020412428214"
  location = "West Europe"
}
resource "azurerm_container_registry" "test" {
  name                = "testacccr211112020412428214"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                  = "West US 2"
    regional_endpoint_enabled = true
  }
}
