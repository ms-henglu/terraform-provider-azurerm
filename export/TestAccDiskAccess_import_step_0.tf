
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506005527612267"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda220506005527612267"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
