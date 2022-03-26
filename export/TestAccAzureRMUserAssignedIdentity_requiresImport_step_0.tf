
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326010902806039"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest84qim"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
