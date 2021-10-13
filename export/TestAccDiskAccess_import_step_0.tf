
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071641533200"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda211013071641533200"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
