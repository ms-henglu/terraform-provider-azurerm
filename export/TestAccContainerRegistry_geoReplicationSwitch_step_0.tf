
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220121044333437604"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr220121044333437604"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["westus2","eastus2"]
}
