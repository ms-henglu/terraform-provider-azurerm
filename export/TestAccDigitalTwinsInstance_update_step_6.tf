

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220527024137687563"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220527024137687563"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
