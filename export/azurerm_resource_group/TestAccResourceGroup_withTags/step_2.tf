
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231417226469"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
