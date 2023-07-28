
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030554198311"
  location = "West Europe"

  managed_by = "test"
}
