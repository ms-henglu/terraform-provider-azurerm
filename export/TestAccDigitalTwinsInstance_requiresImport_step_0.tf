

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-210825031639857040"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-210825031639857040"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
