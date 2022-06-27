
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627122849899194"
  location = "West Europe"
}

data "azuread_application" "test" {
  object_id = ""
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220627122849899194"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  webhook_receiver {
    name                    = "callmyapiaswell"
    service_uri             = "http://example.com/alert"
    use_common_alert_schema = true
  }

  webhook_receiver {
    name                    = "callmysecureapi"
    service_uri             = "http://secureExample.com/alert"
    use_common_alert_schema = true
    aad_auth {
      object_id      = data.azuread_application.test.object_id
      identifier_uri = data.azuread_application.test.identifier_uris[0]
    }
  }
}
