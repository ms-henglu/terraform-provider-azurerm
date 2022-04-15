
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031025505018"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
