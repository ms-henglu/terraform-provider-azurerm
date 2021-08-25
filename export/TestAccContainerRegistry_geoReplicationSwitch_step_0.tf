
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210825044619475761"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                     = "testacccr210825044619475761"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  georeplication_locations = ["westus2","eastus2"]
}
