
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124444612489"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctests1srk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
