
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002228373072"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesth1m48"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
