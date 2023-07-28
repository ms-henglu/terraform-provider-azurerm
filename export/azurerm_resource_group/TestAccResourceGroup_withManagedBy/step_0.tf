
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033001738883"
  location = "West Europe"

  managed_by = "test"
}
