
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023019303580"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctesaog63c4uq"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-04-01T00:00:00Z"
  expiry = "2123-04-01T00:00:00Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230915023019303580"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230915023019303580"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin {
    name      = "acceptanceTestCdnOrigin1"
    host_name = "www.contoso.com"
  }

  delivery_rule {
    name  = "TokenSAS"
    order = 1
    query_string_condition {
      operator         = "Contains"
      negate_condition = true
      match_values     = ["sig"]
    }
    url_redirect_action {
      redirect_type = "PermanentRedirect"
      query_string  = trimprefix(data.azurerm_storage_account_sas.test.sas, "?")
    }
  }
}
