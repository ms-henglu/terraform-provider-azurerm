

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230825024924587446"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230825024924587446"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_sim_group" "test" {
  name              = "acctest-mnsg-230825024924587446"
  location          = azurerm_resource_group.test.location
  mobile_network_id = azurerm_mobile_network.test.id
}


resource "azurerm_mobile_network_sim_group" "import" {
  name              = azurerm_mobile_network_sim_group.test.name
  location          = azurerm_mobile_network_sim_group.test.location
  mobile_network_id = azurerm_mobile_network_sim_group.test.mobile_network_id

}
