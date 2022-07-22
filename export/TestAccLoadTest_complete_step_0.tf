
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035525636692"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220722035525636692"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    Environment = "loadtest"
  }
}
