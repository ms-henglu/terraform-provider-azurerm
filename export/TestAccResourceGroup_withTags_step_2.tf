
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044902356958"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
