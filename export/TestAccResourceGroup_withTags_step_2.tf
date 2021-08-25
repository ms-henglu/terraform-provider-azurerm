
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825032033093931"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
