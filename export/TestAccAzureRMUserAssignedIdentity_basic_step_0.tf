
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429075706116926"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest747la"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
