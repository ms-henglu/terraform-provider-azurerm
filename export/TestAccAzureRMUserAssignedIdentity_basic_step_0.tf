
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005109967253"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestmki43"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
