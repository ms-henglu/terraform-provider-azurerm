
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054820842624"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
