

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220128082358023445"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220128082358023445"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
