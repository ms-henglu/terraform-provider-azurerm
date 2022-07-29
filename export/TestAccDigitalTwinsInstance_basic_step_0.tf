

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220729032646497524"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220729032646497524"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
