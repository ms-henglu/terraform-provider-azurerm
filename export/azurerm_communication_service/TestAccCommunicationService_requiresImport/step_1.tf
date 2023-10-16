


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-231016033531123533"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-231016033531123533"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_communication_service" "import" {
  name                = azurerm_communication_service.test.name
  resource_group_name = azurerm_communication_service.test.resource_group_name
  data_location       = azurerm_communication_service.test.data_location
}
