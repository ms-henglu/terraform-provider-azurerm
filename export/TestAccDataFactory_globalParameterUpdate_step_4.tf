
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220520053846265312"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220520053846265312"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
