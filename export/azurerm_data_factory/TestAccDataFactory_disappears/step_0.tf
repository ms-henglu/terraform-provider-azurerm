
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240112034237881620"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240112034237881620"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
