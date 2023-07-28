

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230728032216369499"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230728032216369499"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
