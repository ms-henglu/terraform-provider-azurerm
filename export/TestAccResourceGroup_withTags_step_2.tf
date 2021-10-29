
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020111717457"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
