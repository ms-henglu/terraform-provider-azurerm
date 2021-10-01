
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054134120642"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
