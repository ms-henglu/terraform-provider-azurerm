

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230313021119780210"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230313021119780210"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
