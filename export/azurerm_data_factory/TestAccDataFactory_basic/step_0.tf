
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221117230800991705"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221117230800991705"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
