
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034411475656"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
