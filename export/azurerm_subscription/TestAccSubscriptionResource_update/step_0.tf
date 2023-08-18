
provider "azurerm" {
  features {}
}

data "azurerm_billing_mca_account_scope" "test" {
  billing_account_name = "ARM_BILLING_ACCOUNT"
  billing_profile_name = ""
  invoice_section_name = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-230818024919615460"
  subscription_name = "testAccSubscription 230818024919615460"
  billing_scope_id  = data.azurerm_billing_mca_account_scope.test.id
}
