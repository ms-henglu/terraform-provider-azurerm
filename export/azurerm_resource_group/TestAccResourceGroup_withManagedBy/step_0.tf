
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061453145702"
  location = "West Europe"

  managed_by = "test"
}
