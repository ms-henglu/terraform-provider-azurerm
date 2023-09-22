
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054820847883"
  location = "West Europe"

  managed_by = "test"
}
