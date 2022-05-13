
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513023726557050"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
