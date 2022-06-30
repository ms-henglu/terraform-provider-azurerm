
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630224106175492"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
