
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040212538111"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestagl3h"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
