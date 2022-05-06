
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020419778141"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
