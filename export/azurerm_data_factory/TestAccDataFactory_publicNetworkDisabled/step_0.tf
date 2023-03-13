
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230313021052289223"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230313021052289223"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
