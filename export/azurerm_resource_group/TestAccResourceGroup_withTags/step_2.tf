
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064524780817"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
