

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220811053212033250"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220811053212033250"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
