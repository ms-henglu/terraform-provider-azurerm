
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011318685717"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230512011318685717"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
