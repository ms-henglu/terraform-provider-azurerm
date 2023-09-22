
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061836121706"
  location = "West Europe"

  managed_by = "test"
}
