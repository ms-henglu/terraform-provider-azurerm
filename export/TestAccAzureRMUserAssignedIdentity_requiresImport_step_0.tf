
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075549785470"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest4n2eh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
