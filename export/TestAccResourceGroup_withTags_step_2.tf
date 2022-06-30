
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630211256617568"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
