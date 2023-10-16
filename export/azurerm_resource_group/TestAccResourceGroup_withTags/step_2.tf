
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034629731202"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
