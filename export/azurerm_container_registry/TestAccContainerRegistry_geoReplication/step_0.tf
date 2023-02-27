
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230227175253629025"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230227175253629025"
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
