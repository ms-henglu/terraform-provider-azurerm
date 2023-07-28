
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230728030335843156"
  location = "West Europe"
}


resource "azurerm_network_function_azure_traffic_collector" "test" {
  name                = "acctest-nfatc-230728030335843156"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}


resource "azurerm_network_function_azure_traffic_collector" "import" {
  name                = azurerm_network_function_azure_traffic_collector.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
