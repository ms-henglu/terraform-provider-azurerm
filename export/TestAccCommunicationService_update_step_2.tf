

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-220811052956612981"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-220811052956612981"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Australia"

  tags = {
    env = "Test2"
  }
}
