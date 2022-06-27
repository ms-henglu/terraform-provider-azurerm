
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627123019206738"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
