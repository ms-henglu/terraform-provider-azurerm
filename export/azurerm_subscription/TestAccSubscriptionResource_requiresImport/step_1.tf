

provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-221117231558683598"
  subscription_name = "testAccSubscription 221117231558683598"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}


resource "azurerm_subscription" "import" {
  alias             = azurerm_subscription.test.alias
  subscription_name = azurerm_subscription.test.subscription_name
  billing_scope_id  = azurerm_subscription.test.billing_scope_id
}
