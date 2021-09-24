
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004608472542"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest3cf3u"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
