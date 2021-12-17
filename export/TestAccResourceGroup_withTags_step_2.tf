
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075748733513"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
