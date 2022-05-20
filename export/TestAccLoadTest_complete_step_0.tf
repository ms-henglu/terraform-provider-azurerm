
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040833483017"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220520040833483017"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    Environment = "loadtest"
  }
}
