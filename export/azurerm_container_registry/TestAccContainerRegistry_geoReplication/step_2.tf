
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230707010154922729"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230707010154922729"
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
