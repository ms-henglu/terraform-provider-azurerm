
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075718301985"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestp10u7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
