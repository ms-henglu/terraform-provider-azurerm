
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022520994943"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuhykc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
