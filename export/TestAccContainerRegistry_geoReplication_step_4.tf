
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211210034504737274"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr211210034504737274"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "westus2"
  }
  georeplications {
    location = "eastus2"
  }
}
