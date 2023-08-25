
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025233958747"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlogicapp-230825025233958747"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "test" {
  name                = "acctestautomation-230825025233958747"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name

  scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  ]

  action {
    type        = "logicapp"
    resource_id = azurerm_logic_app_workflow.test.id
    trigger_url = "https://example.net/this_is_never_validated_by_azure"
  }

  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "properties.metadata.title"
        operator       = "Equals"
        expected_value = "Tony Iommi"
        property_type  = "String"
      }
      rule {
        property_path  = "properties.metadata.title"
        operator       = "Equals"
        expected_value = "Ozzy Osbourne"
        property_type  = "String"
      }
    }
    rule_set {
      rule {
        property_path  = "properties.metadata.title"
        operator       = "Equals"
        expected_value = "Bill Ward"
        property_type  = "String"
      }
      rule {
        property_path  = "properties.metadata.title"
        operator       = "Equals"
        expected_value = "Geezer Butler"
        property_type  = "String"
      }
    }
  }
}
