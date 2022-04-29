
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065303835192"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220429065303835192"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
