
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004649052807"
  location = "West Europe"

  managed_by = "test"
}
