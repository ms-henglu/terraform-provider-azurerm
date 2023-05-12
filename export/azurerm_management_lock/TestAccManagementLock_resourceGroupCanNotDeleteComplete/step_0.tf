
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011318683650"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230512011318683650"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
