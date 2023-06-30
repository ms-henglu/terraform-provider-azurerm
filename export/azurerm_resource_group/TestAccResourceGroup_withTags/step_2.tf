
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033843466850"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
