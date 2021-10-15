
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014906059944"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestus2ox"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
