

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230526085026316049"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230526085026316049"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
