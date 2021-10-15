
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014528495118"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211015014528495118"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
