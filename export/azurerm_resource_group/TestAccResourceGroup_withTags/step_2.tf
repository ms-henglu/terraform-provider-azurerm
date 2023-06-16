
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075350386656"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
