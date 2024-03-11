
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033021393900"
  location = "West Europe"

  managed_by = "test"
}
