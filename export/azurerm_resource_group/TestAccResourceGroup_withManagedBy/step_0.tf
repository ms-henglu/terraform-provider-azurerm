
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112225157590350"
  location = "West Europe"

  managed_by = "test"
}
