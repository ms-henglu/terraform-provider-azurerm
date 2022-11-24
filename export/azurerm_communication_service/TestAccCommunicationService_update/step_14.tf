

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-221124181340570772"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-221124181340570772"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "India"

  tags = {
    env = "Test2"
  }
}
