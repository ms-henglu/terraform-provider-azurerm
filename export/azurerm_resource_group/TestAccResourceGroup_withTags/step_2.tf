
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034526013030"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
