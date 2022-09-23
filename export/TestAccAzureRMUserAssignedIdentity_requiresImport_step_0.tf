
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012118616295"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestyab9r"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
