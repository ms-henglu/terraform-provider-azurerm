
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019061020144681"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
