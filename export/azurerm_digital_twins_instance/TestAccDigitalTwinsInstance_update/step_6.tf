

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230825024450589585"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230825024450589585"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
