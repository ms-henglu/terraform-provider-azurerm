
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015925644399"
  location = "West Europe"

  managed_by = "test"
}
