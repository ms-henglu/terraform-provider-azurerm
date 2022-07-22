
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035656515848"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestn9e2o"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
