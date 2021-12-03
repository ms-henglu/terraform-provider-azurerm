
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161829269508"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
