
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002407326609"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
