
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422012305555388"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
