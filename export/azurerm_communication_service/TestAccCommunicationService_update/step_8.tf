

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221216013214307018"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221216013214307018"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Canada"

  tags = {
    env = "Test2"
  }
}
