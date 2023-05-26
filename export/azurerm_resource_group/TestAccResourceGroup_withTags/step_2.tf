
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085758325166"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
