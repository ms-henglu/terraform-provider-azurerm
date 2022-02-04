
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060348312196"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestiv9ps"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
