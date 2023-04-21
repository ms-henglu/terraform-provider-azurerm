
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230421022543477916"
  location = "eastus"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230421022543477916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"

  tags = {
    key = "value"
  }

}
