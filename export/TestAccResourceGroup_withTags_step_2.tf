
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075851705697"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
