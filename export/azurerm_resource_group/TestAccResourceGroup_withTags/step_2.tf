
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033021394291"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
