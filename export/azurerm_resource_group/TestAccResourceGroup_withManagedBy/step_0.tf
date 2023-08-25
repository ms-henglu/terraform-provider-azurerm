
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025220318588"
  location = "West Europe"

  managed_by = "test"
}
