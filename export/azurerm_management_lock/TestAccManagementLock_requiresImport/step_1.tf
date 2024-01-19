

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728742386"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240119025728742386"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}


resource "azurerm_management_lock" "import" {
  name       = azurerm_management_lock.test.name
  scope      = azurerm_management_lock.test.scope
  lock_level = azurerm_management_lock.test.lock_level
}
