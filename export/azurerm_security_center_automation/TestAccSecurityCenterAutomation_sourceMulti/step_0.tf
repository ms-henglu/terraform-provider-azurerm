
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024731409613"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlogicapp-230818024731409613"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "test" {
  name                = "acctestautomation-230818024731409613"
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
        property_path  = "properties.metadata.severity"
        operator       = "Equals"
        expected_value = "Low"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "Assessments"
    rule_set {
      rule {
        property_path  = "properties.metadata.severity"
        operator       = "Equals"
        expected_value = "Low"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "SubAssessments"
    rule_set {
      rule {
        property_path  = "properties.metadata.severity"
        operator       = "Equals"
        expected_value = "Low"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  source {
    event_source = "RegulatoryComplianceAssessment"
  }

  source {
    event_source = "RegulatoryComplianceAssessmentSnapshot"
  }

  source {
    event_source = "SecureScoreControlsSnapshot"
  }

  source {
    event_source = "SecureScoresSnapshot"
  }

}
