
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054005068622"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest3edhd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
