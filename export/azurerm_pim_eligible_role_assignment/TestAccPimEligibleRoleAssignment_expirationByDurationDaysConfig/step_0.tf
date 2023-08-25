
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Disk Backup Reader"
}


data "azuread_domains" "test" {
  only_initial = true
}

resource "azuread_user" "test" {
  user_principal_name = "acctestUser-2308250240382888741@${data.azuread_domains.test.domains.0.domain_name}"
  display_name        = "acctestUser-2308250240382888741"
  password            = "p@$$Wdd7yss"
}

resource "azuread_group" "test" {
  display_name     = "acctest-group-230825024038288874"
  security_enabled = true
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024038288874"
  location = "West Europe"
}
resource "azurerm_virtual_network" "test" {
  name                = "amtestVNET1-230825024038288874"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "time_static" "test" {}

resource "azurerm_pim_eligible_role_assignment" "test" {
  scope              = azurerm_virtual_network.test.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.test.id}"
  principal_id       = azuread_user.test.object_id

  schedule {
    start_date_time = time_static.test.rfc3339
    expiration {
      duration_days = 8
    }
  }

  justification = "Expiration Duration Set"

  ticket {
    number = "1"
    system = "example ticket system"
  }
}
