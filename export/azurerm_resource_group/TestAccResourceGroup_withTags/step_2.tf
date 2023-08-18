
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024717352253"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
