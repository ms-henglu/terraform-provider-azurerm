
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235250233638"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest8agb6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
