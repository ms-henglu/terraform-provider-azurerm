
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125405936792"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestf8e6k"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
