

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-240315122914967812"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240315122914967812"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
