
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002222419136"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest0a33q"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
