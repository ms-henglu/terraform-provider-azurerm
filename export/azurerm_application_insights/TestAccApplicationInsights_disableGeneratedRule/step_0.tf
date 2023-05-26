
provider "azurerm" {
  features {
    application_insights {
      disable_generated_rule = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230526084537247313"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230526084537247313"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}
