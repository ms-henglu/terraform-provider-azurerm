
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035234761565"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
