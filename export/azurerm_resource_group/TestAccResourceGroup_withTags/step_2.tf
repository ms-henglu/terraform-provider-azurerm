
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152761996"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
