


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-240119024934577171"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240119024934577171"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_digital_twins_instance" "import" {
  name                = azurerm_digital_twins_instance.test.name
  resource_group_name = azurerm_digital_twins_instance.test.resource_group_name
  location            = azurerm_digital_twins_instance.test.location
}
