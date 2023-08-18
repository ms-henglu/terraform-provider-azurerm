
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024717357519"
  location = "West Europe"

  managed_by = "test"
}
