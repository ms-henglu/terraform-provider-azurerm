
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030308698679"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestiw4i0"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
