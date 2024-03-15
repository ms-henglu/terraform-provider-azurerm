
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123944592625"
  location = "West Europe"

  managed_by = "test"
}
