
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022750521903"
  location = "West Europe"

  managed_by = "test"
}
