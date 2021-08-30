
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084420873289"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
