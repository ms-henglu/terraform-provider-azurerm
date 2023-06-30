
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033843463372"
  location = "West Europe"

  managed_by = "test"
}
