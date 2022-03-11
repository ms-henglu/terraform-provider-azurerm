
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032835549070"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest0f6ao"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
