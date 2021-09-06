
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022054064347"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-210906022054064347"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
