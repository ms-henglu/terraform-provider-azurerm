
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030621592262"
  location = "West Europe"

  managed_by = "test"
}
