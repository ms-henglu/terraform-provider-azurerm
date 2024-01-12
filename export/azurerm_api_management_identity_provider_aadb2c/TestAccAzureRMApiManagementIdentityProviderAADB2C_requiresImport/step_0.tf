
provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id     = "ARM_TEST_B2C_TENANT_ID"
  client_id     = "ARM_TEST_B2C_CLIENT_ID"
  client_secret = "ARM_TEST_B2C_CLIENT_SECRET"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-240112223839715641"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240112223839715641"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azuread_application" "test" {
  display_name = "acctestAM-240112223839715641"
  web {
    redirect_uris = [azurerm_api_management.test.developer_portal_url]

    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
}

resource "azuread_application_password" "test" {
  application_object_id = azuread_application.test.object_id
}

resource "azurerm_api_management_identity_provider_aadb2c" "test" {
  resource_group_name    = azurerm_resource_group.test.name
  api_management_name    = azurerm_api_management.test.name
  client_id              = azuread_application.test.application_id
  client_secret          = azuread_application_password.test.value
  allowed_tenant         = "ARM_TEST_B2C_TENANT_SLUG.onmicrosoft.com"
  signin_tenant          = "ARM_TEST_B2C_TENANT_SLUG.onmicrosoft.com"
  authority              = "ARM_TEST_B2C_TENANT_SLUG.b2clogin.com"
  signin_policy          = "B2C_1_Login"
  signup_policy          = "B2C_1_Signup"
  profile_editing_policy = "B2C_1_EditProfile"
  password_reset_policy  = "B2C_1_ResetPassword"

  depends_on = [azuread_application_password.test]
}
