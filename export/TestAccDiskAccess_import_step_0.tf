
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014023102929"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda211015014023102929"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
