
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610093200208287"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
