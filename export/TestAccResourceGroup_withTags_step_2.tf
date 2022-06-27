
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124629658149"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
