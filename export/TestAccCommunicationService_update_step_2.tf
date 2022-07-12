

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-220712042032857033"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-220712042032857033"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Australia"

  tags = {
    env = "Test2"
  }
}
