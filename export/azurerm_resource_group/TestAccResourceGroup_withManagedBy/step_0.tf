
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152771972"
  location = "West Europe"

  managed_by = "test"
}
