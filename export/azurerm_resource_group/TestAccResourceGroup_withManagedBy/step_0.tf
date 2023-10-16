
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034629737900"
  location = "West Europe"

  managed_by = "test"
}
