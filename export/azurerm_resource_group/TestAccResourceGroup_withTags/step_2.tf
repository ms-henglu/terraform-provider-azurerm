
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172717561961"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
