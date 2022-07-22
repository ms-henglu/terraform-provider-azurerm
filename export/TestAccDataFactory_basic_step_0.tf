
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220722035139787233"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220722035139787233"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
