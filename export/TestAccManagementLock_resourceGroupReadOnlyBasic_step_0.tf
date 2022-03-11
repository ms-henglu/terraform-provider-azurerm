
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042937680177"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220311042937680177"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
