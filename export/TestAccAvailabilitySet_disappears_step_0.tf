
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722051724509713"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220722051724509713"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
