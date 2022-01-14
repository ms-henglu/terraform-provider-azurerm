
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064417221439"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesttapgd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
