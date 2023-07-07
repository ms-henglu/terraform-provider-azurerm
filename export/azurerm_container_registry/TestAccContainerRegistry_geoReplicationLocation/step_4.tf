
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230707003619889764"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230707003619889764"
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
