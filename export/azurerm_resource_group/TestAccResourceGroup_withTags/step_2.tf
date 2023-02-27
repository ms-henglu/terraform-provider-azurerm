
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175929564636"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
