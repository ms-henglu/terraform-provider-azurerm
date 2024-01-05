
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064326558228"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-240105064326558228"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
