
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064609284884"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
