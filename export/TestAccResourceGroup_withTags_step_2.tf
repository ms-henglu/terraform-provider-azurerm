
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715014934204396"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
