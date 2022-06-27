
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627130159866785"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
