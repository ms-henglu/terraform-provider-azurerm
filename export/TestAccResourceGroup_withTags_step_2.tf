
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905050415862731"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
