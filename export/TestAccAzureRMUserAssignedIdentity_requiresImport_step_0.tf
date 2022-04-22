
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422012128919243"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvap67"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
