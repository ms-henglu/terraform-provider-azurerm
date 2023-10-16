
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-231016033638146863"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr231016033638146863"
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
