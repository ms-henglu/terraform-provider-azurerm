
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211021234910499655"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211021234910499655"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
