

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-211013071828704295"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-211013071828704295"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
