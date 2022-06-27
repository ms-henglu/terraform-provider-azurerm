
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220627130944191780"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220627130944191780"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  identity {
    type = "SystemAssigned"
  }
}


