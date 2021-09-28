
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075718300436"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesty36zz"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
