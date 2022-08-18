
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235553890809"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
