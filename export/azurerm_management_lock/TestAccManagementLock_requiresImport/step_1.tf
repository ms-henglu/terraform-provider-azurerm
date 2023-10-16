

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034629738570"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231016034629738570"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}


resource "azurerm_management_lock" "import" {
  name       = azurerm_management_lock.test.name
  scope      = azurerm_management_lock.test.scope
  lock_level = azurerm_management_lock.test.lock_level
}
