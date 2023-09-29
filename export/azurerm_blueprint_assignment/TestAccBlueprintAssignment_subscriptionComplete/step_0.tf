
provider "azurerm" {
  subscription_id = ""
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "test" {}

data "azurerm_blueprint_definition" "test" {
  name     = "testAcc_subscriptionComplete"
  scope_id = data.azurerm_subscription.test.id
}

data "azurerm_blueprint_published_version" "test" {
  scope_id       = data.azurerm_blueprint_definition.test.scope_id
  blueprint_name = data.azurerm_blueprint_definition.test.name
  version        = "v0.1_testAcc"
}

resource "azurerm_resource_group" "test" {
  name     = "accTestRG-bp-230929064453955126"
  location = "westeurope"

  tags = {
    testAcc = "true"
  }
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "bp-user-230929064453955126"
}

resource "azurerm_role_assignment" "operator" {
  scope                = data.azurerm_subscription.test.id
  role_definition_name = "Blueprint Operator"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "owner" {
  scope                = data.azurerm_subscription.test.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_blueprint_assignment" "test" {
  name                   = "testAccBPAssignment230929064453955126"
  target_subscription_id = data.azurerm_subscription.test.id
  version_id             = data.azurerm_blueprint_published_version.test.id
  location               = "West Europe"

  lock_mode = "AllResourcesDoNotDelete"

  lock_exclude_principals = [
    data.azurerm_client_config.current.object_id,
  ]

  lock_exclude_actions = [
    "Microsoft.Resources/subscriptions/resourceGroups/write"
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  resource_groups = <<GROUPS
    {
      "ResourceGroup": {
        "name": "accTestRG-BP-230929064453955126"
      }
    }
  GROUPS

  parameter_values = <<VALUES
    {
      "allowedlocationsforresourcegroups_listOfAllowedLocations": {
        "value": ["westus", "westus2", "eastus", "centralus", "centraluseuap", "southcentralus", "northcentralus", "westcentralus", "eastus2", "eastus2euap", "brazilsouth", "brazilus", "northeurope", "westeurope", "eastasia", "southeastasia", "japanwest", "japaneast", "koreacentral", "koreasouth", "indiasouth", "indiawest", "indiacentral", "australiaeast", "australiasoutheast", "canadacentral", "canadaeast", "uknorth", "uksouth2", "uksouth", "ukwest", "francecentral", "francesouth", "australiacentral", "australiacentral2", "uaecentral", "uaenorth", "southafricanorth", "southafricawest", "switzerlandnorth", "switzerlandwest", "germanynorth", "germanywestcentral", "norwayeast", "norwaywest"]
      }
    }
  VALUES

  depends_on = [
    azurerm_role_assignment.operator,
    azurerm_role_assignment.owner
  ]
}
