
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030459298134"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
