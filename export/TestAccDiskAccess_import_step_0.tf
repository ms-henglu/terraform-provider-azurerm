
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812014802117147"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda220812014802117147"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
