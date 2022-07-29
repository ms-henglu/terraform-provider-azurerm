
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729033217333557"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
