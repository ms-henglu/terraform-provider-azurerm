
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002222414482"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestpgd8l"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
