
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221021034023727708"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221021034023727708"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
