

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221111013215880747"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221111013215880747"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"

  tags = {
    env = "Test"
  }
}
