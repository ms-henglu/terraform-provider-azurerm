
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203014139051372"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest2fymw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
