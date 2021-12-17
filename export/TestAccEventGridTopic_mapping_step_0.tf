
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035256416635"
  location = "West Europe"
}
resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211217035256416635"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  input_schema        = "CustomEventSchema"
  input_mapping_fields {
    topic      = "test"
    event_type = "test"
  }
  input_mapping_default_values {
    data_version = "1.0"
    subject      = "DefaultSubject"
  }
}
