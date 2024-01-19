
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707319581"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda240119024707319581"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
