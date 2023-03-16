
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222219699135"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
