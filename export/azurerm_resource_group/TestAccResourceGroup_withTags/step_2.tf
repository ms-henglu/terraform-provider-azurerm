
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052631933371"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
