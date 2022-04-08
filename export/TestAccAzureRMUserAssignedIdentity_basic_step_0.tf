
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051608087788"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestz2h2u"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
