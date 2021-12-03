

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-211203161338355420"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-211203161338355420"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
