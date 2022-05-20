
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040940756993"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestxiufp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
