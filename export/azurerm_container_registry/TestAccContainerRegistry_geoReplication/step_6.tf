
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221111020216873510"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221111020216873510"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location                = "westus2"
    zone_redundancy_enabled = true
  }
  georeplications {
    location                  = "eastus2"
    regional_endpoint_enabled = true
    tags = {
      foo = "bar"
    }
  }
}
