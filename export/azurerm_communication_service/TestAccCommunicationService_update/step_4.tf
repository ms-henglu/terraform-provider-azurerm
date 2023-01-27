

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230127045107489265"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-230127045107489265"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Africa"

  tags = {
    env = "Test2"
  }
}
