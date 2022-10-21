

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221021033854180224"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221021033854180224"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Australia"

  tags = {
    env = "Test2"
  }
}
