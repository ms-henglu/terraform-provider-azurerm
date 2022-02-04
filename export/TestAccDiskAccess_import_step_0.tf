
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204055814314139"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda220204055814314139"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
