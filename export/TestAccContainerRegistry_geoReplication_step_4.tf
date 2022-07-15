
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220715004256772028"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220715004256772028"
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
