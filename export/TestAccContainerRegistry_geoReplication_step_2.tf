
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-210910021228785333"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr210910021228785333"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "eastus2"
    tags = {
      Environment = "Production"
    }
  }
}
