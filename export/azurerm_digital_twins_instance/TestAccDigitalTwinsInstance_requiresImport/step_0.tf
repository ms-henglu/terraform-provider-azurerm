

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230922054042448415"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230922054042448415"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
