
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024120290337"
  location = "West Europe"

  managed_by = "test"
}
