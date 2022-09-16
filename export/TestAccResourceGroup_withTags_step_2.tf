
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011939218247"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
