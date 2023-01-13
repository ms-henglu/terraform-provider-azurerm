

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230113180823490743"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-230113180823490743"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Africa"

  tags = {
    env = "Test2"
  }
}
