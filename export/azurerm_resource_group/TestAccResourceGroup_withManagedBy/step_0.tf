
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064524782726"
  location = "West Europe"

  managed_by = "test"
}
