
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235425681068"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest2xsyn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
