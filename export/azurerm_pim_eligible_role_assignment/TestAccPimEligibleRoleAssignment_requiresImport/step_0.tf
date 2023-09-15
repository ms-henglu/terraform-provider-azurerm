
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "AcrPull"
}


data "azuread_domains" "test" {
  only_initial = true
}

resource "azuread_user" "test" {
  user_principal_name = "acctestUser-2309150229052612901@${data.azuread_domains.test.domains.0.domain_name}"
  display_name        = "acctestUser-2309150229052612901"
  password            = "p@$$Wdek313"
}

resource "azuread_group" "test" {
  display_name     = "acctest-group-230915022905261290"
  security_enabled = true
}



resource "time_static" "test" {}

resource "azurerm_pim_eligible_role_assignment" "test" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.test.id}"
  principal_id       = azuread_user.test.object_id

  schedule {
    start_date_time = time_static.test.rfc3339
    expiration {
      duration_hours = 3
    }
  }

  justification = "Expiration Duration Set"

  ticket {
    number = "1"
    system = "example ticket system"
  }
}
