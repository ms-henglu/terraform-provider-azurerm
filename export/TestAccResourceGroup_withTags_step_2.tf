
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051341555768"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
