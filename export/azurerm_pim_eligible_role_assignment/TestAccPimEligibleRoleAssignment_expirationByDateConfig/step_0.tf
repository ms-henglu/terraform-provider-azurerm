
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Workbook Reader"
}


data "azuread_domains" "test" {
  only_initial = true
}

resource "azuread_user" "test" {
  user_principal_name = "acctestUser-2403110313550914011@${data.azuread_domains.test.domains.0.domain_name}"
  display_name        = "acctestUser-2403110313550914011"
  password            = "p@$$Wdgdbe4"
}

resource "azuread_group" "test" {
  display_name     = "acctest-group-240311031355091401"
  security_enabled = true
}



resource "time_static" "test" {}
resource "time_offset" "test" {
  offset_days = 7
}

resource "azurerm_pim_eligible_role_assignment" "test" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.test.id}"

  principal_id = azuread_group.test.object_id

  schedule {
    start_date_time = time_static.test.rfc3339
    expiration {
      end_date_time = time_offset.test.rfc3339
    }
  }

  justification = "Expiration End Date Set"

  ticket {
    number = "1"
    system = "example ticket system"
  }
}
