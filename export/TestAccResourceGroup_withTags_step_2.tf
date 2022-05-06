
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010159622127"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
