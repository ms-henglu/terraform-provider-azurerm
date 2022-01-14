
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064554612109"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
