
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422025718166109"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
