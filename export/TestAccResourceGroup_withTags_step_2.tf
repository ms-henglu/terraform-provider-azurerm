
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044927512007"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
