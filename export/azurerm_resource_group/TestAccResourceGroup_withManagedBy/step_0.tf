
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810144141545021"
  location = "West Europe"

  managed_by = "test"
}
