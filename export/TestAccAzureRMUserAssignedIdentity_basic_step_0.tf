
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180547704446"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestp2ta3"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
