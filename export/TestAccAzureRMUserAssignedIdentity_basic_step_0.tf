
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035602550234"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest33k8w"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
