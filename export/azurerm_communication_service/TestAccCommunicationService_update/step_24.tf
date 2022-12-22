

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221222034340507577"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221222034340507577"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "UAE"

  tags = {
    env = "Test2"
  }
}
