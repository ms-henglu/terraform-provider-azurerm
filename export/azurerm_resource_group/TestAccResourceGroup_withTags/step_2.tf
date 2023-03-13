
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021819928810"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
