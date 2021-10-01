
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021027521506"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestbpiq1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
