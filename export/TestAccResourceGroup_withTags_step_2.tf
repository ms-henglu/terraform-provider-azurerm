
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124122600108923"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
