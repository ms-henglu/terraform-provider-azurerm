
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235250236514"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest8mi3g"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
