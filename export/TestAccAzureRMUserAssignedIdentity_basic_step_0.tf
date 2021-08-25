
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825041056284926"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestkp1mi"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
