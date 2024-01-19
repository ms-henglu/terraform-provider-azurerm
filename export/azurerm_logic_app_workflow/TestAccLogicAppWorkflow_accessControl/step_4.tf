

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240119022328334637"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240119022328334637"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  enabled             = false

  access_control {
    content {
      allowed_caller_ip_address_range = ["10.10.3.0/24"]
    }

    action {
      allowed_caller_ip_address_range = ["10.10.4.0/24"]
    }

    trigger {
      allowed_caller_ip_address_range = ["10.10.5.0/24"]

      open_authentication_policy {
        name = "testpolicy4"

        claim {
          name  = "iss"
          value = "https://sts.windows.net/"
        }

        claim {
          name  = "testclaimname"
          value = "testclaimvalue"
        }
      }
    }

    workflow_management {
      allowed_caller_ip_address_range = ["10.10.6.0/24"]
    }
  }
}


resource "azurerm_logic_app_action_custom" "test" {
  name         = "test"
  logic_app_id = azurerm_logic_app_workflow.test.id

  body = <<BODY
{
    "description": "A variable to configure the auto expiration age in days. Configured in negative number. Default is -30 (30 days old).",
    "inputs": {
        "variables": [
            {
                "name": "ExpirationAgeInDays",
                "type": "Integer",
                "value": -30
            }
        ]
    },
    "runAfter": {},
    "type": "InitializeVariable"
}
BODY
}

