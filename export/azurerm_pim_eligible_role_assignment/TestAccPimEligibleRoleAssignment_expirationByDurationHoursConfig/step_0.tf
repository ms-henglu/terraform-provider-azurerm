
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "ContainerApp Reader"
}


data "azuread_domains" "test" {
  only_initial = true
}

resource "azuread_user" "test" {
  user_principal_name = "acctestUser-2401120338531132601@${data.azuread_domains.test.domains.0.domain_name}"
  display_name        = "acctestUser-2401120338531132601"
  password            = "p@$$Wd0mxjg"
}

resource "azuread_group" "test" {
  display_name     = "acctest-group-240112033853113260"
  security_enabled = true
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033853113260"
  location = "West Europe"
}

resource "time_static" "test" {}

resource "azurerm_pim_eligible_role_assignment" "test" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.test.id}"
  principal_id       = azuread_user.test.object_id

  schedule {
    start_date_time = time_static.test.rfc3339
    expiration {
      duration_hours = 8
    }
  }

  justification = "Expiration Duration Set"

  ticket {
    number = "1"
    system = "example ticket system"
  }
}
