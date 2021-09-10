
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021650332553"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvj6uj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
