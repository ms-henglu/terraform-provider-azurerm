

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230120054332763705"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-230120054332763705"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Korea"

  tags = {
    env = "Test2"
  }
}
