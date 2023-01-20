
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120055048126953"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
