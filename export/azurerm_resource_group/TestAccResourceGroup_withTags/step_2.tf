
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015925640550"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
