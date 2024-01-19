
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728755622"
  location = "West Europe"

  managed_by = "test"
}
