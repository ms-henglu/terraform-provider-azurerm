
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003539986583"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda230707003539986583"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  tags = {
    environment = "staging"
  }
}
