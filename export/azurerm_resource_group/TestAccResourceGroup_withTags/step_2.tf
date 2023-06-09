
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091922811749"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
