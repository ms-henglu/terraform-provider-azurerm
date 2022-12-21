
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204753491845"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
