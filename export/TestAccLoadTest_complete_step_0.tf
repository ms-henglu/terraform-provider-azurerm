
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220909034528964093"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220909034528964093"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    Environment = "loadtest"
  }
}
