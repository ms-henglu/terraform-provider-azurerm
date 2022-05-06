
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010017740797"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvomae"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
