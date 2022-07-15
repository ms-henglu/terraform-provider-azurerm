
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004832620267"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
