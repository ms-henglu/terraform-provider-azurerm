
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161645427139"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestq844t"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
