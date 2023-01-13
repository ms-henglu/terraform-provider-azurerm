
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181110687680"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-230113181110687680"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  input_schema = "CustomEventSchema"

  input_mapping_fields {
    topic      = "test"
    event_type = "test"
  }

  input_mapping_default_values {
    data_version = "1.0"
    subject      = "DefaultSubject"
  }
}
