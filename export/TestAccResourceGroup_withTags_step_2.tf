
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021827335520"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
