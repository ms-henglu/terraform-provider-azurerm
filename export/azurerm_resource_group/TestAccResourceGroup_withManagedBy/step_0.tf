
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072455219437"
  location = "West Europe"

  managed_by = "test"
}
