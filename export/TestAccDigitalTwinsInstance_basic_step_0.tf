

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220712042221197718"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220712042221197718"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
