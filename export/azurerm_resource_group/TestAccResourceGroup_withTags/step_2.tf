
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061453147213"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
