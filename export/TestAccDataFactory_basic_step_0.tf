
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627131045435277"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220627131045435277"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
