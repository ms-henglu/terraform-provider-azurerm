
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422011655516322"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda220422011655516322"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
