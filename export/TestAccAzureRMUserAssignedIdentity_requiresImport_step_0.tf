
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031949741576"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "accteste3je2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
