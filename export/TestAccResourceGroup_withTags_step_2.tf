
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004809397583"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
