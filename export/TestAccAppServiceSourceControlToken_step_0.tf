
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "qmja9yil8lctailf6xwdktrhn1mnvr27ese6op8bs"
  token_secret = "dljdal4qc7ge1pmfounjbeanumthur762o66eky3i"
}
