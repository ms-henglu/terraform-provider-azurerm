

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221111020124456750"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221111020124456750"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Africa"

  tags = {
    env = "Test2"
  }
}
