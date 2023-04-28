
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_provider_registration" "test" {
  name = "Microsoft.ApiSecurity"
  feature {
    name       = "PP2CanaryAccessDEV"
    registered = false
  }
  feature {
    name       = "PP3CanaryAccessDEV"
    registered = false
  }
}
