
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044319942414"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220121044319942414"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
