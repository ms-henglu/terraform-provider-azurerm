
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234246013524"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
