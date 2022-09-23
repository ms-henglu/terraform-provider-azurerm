
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012254545245"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
