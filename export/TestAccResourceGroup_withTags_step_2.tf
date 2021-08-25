
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045137914128"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
