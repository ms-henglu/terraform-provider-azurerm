
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210924004045368727"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210924004045368727"
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
