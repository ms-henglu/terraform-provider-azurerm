


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-210825044553737963"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-210825044553737963"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_communication_service" "import" {
  name                = azurerm_communication_service.test.name
  resource_group_name = azurerm_communication_service.test.resource_group_name
  data_location       = azurerm_communication_service.test.data_location
}
