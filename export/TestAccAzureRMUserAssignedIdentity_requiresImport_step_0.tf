
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034219861814"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestk24be"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
