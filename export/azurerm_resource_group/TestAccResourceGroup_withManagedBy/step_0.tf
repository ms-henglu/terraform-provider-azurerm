
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035056399066"
  location = "West Europe"

  managed_by = "test"
}
