

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-231020041013245749"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-231020041013245749"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
