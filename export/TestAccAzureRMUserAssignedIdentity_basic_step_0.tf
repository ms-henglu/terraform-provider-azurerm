
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040212539130"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestz8yto"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
