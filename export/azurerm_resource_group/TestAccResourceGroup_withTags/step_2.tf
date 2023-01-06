
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031901458519"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
