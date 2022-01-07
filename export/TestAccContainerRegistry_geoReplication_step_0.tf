
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220107063818121543"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220107063818121543"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "westus2"
    tags = {
      Environment = "Production"
    }
  }
}
