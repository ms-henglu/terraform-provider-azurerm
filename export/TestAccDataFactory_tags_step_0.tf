
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220506005636130501"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220506005636130501"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
