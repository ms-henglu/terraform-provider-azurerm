
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010908449613"
  location = "West Europe"

  managed_by = "test"
}
