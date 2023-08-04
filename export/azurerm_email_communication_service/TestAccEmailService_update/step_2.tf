

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230804025552352893"
  location = "West Europe"
}


resource "azurerm_email_communication_service" "test" {
  name                = "acctest-CommunicationService-230804025552352893"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"

  tags = {
    env = "Test2"
  }
}
