
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810144141541180"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
