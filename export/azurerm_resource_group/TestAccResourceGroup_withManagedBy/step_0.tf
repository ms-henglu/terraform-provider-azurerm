
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012337674748"
  location = "West Europe"

  managed_by = "test"
}
