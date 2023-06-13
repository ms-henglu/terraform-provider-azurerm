
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072535887463"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
