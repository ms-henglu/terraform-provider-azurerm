

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230707003504758270"
  location = "West Europe"
}


resource "azurerm_email_communication_service" "test" {
  name                = "acctest-CommunicationService-230707003504758270"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"
}
