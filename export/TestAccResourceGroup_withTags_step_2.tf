
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005242546876"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
