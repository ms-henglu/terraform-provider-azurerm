


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230721014642752659"
  location = "West Europe"
}


resource "azurerm_email_communication_service" "test" {
  name                = "acctest-CommunicationService-230721014642752659"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"
}


resource "azurerm_email_communication_service" "import" {
  name                = azurerm_email_communication_service.test.name
  resource_group_name = azurerm_email_communication_service.test.resource_group_name
  data_location       = azurerm_email_communication_service.test.data_location
}
