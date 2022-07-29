
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729033029254810"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvd8mt"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
