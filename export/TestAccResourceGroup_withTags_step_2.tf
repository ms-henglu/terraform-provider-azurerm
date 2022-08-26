
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826010540136074"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
