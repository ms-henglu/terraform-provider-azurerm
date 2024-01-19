
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707319137"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-240119024707319137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
