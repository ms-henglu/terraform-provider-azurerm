
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063036418428"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-230203063036418428"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
