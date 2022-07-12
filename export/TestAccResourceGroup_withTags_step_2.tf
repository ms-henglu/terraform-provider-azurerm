
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042722530067"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
