
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012337677923"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
