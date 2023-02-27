

				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230227175736431463"
  location = "eastus"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230227175736431463"
  resource_group_name = azurerm_resource_group.test.name
  location            = "eastus"
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_slice" "test" {
  name              = "acctest-mns-230227175736431463"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = "eastus"
  description       = "my favorite slice2"
  single_network_slice_selection_assistance_information {
    slice_service_type = 1
  }

  tags = {
    key = "value"
  }

}
