

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221202035301507692"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221202035301507692"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Korea"

  tags = {
    env = "Test2"
  }
}
