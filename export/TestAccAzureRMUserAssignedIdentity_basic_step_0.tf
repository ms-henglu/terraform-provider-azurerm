
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053607673686"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest0l6lp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
