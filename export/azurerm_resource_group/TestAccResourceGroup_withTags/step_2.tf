
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040340500574"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
