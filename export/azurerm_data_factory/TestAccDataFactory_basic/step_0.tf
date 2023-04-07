
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230407023248957149"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230407023248957149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
