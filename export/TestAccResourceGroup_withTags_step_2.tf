
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231401253483"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
