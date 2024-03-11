
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031615485632"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-240311031615485632"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
