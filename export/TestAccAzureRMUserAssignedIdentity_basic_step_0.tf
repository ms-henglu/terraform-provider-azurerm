
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014523526062"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesty76ft"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
