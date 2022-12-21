

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221221204036452244"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221221204036452244"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "France"

  tags = {
    env = "Test2"
  }
}
