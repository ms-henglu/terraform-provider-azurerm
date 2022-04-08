

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220408051218131426"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220408051218131426"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
