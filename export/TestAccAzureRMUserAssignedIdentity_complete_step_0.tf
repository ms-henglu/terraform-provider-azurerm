
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052822689282"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestf0ppr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
