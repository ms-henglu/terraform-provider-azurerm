
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230526084836002482"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230526084836002482"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "eastus2"
  }
}
