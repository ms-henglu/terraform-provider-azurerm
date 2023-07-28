
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025312692383"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda230728025312692383"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
