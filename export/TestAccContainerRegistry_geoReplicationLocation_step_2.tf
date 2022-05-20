
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220520053746426839"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220520053746426839"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "eastus2"
  }
}
