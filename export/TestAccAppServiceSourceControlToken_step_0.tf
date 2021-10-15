
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "tinnfrg87dskycoa7kz7c88ok89nbxofpugimwg7r"
  token_secret = "ugdwhcqli0lcjuwmhtjrok4pyv1mb1o6kkd0ky28h"
}
