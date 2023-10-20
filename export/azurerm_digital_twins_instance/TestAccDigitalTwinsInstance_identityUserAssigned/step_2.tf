

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-231020041013256810"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-231020041013256810"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
