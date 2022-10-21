
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221021031010251063"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr221021031010251063"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  georeplications {
    location = "westus2"
  }
}
