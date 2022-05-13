
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220513023141084128"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220513023141084128"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
