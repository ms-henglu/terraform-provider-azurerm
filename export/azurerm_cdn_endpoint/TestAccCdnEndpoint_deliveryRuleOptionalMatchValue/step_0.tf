
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064510070654"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230929064510070654"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230929064510070654"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin_host_header = "www.contoso.com"

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }

  delivery_rule {
    name  = "cookieCondition"
    order = 1

    cookies_condition {
      selector = "abc"
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "postArg"
    order = 2

    post_arg_condition {
      selector = "abc"
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "queryString"
    order = 3

    query_string_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "remoteAddress"
    order = 4

    remote_address_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "requestBody"
    order = 5

    request_body_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "requestHeader"
    order = 6

    request_header_condition {
      selector = "abc"
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "requestUri"
    order = 7

    request_uri_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "uriFileExtension"
    order = 8

    url_file_extension_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "uriFileName"
    order = 9

    url_file_name_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }

  delivery_rule {
    name  = "uriPath"
    order = 10

    url_path_condition {
      operator = "Any"
    }

    modify_response_header_action {
      action = "Delete"
      name   = "Content-Language"
    }
  }
}
