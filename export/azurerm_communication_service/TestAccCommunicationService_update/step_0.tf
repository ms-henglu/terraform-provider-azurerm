

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-240119024633608158"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-240119024633608158"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"

  tags = {
    env = "Test"
  }
}
