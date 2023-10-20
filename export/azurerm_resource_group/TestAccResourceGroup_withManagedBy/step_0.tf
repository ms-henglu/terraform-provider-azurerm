
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041756197149"
  location = "West Europe"

  managed_by = "test"
}
