
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627124055601216"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220627124055601216"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
