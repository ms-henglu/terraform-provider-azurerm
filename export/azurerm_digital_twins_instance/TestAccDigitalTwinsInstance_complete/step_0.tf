

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-240119024934575117"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240119024934575117"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    ENV = "Test"
  }
}
