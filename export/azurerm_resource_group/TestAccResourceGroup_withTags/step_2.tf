
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165453991028"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
