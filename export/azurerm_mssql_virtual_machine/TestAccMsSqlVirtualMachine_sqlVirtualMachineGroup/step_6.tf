



provider "azurerm" {
  features {}
}

locals {
  domain_controller_vm_name     = "acctestu6ec3dc"
  active_directory_netbios_name = "acctestu6ec3"
  active_directory_domain_name  = "acctestu6ec3.local"
  domain_controller_vm_fqdn     = join(".", [local.domain_controller_vm_name, local.active_directory_domain_name])
  admin_username                = "adminuser"
  admin_password                = "P@ssw0rd1234!"

  auto_logon_data    = "<AutoLogon><Password><Value>${local.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${local.admin_username}</Username></AutoLogon>"
  first_logon_data   = file("testdata/FirstLogonCommands.xml")
  custom_data_params = "Param($RemoteHostName = \"${local.domain_controller_vm_fqdn}\", $ComputerName = \"${local.domain_controller_vm_name}\")"
  custom_data        = base64encode(join(" ", [local.custom_data_params, file("testdata/winrm.ps1")]))

  import_command           = "Import-Module ADDSDeployment"
  password_command         = "$password = ConvertTo-SecureString ${local.admin_password} -AsPlainText -Force"
  install_ad_command       = "Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools"
  configure_ad_command     = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${local.active_directory_domain_name} -DomainNetbiosName ${local.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command         = "shutdown -r -t 10"
  exit_code_hack           = "exit 0"
  configure_domain_command = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041508315253"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020041508315253"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_servers         = ["10.0.1.4", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controllers" {
  name                 = "domain-controllers"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "domain_controller" {
  name                = "acctestnic-231020041508315253-dc"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    subnet_id                     = azurerm_subnet.domain_controllers.id
  }
}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  name                = local.domain_controller_vm_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  size                = "Standard_F2"
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  custom_data         = local.custom_data

  network_interface_ids = [
    azurerm_network_interface.domain_controller.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  additional_unattend_content {
    content = local.auto_logon_data
    setting = "AutoLogon"
  }

  additional_unattend_content {
    content = local.first_logon_data
    setting = "FirstLogonCommands"
  }
}


resource "azurerm_virtual_machine_extension" "custom_script" {
  name                 = "set-ad-user"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"Get-ADUser ${local.admin_username} | Set-ADUser -UserPrincipalName ${local.admin_username}@${local.active_directory_domain_name}\""
  }
SETTINGS
}


resource "azurerm_subnet" "domain_clients" {
  name                 = "domain-clients"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "client" {
  name                = "acctestnic-client-231020041508315253"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.domain_clients.id
  }
}

resource "azurerm_windows_virtual_machine" "client" {
  name                = "acctest-u6ec3"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  size                = "Standard_F2"
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  custom_data         = local.custom_data

  network_interface_ids = [
    azurerm_network_interface.client.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2019-WS2019"
    sku       = "SQLDEV"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "join_domain" {
  name                 = "join-domain"
  virtual_machine_id   = azurerm_windows_virtual_machine.client.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = local.active_directory_domain_name,
    OUPath  = "",
    User    = "${local.active_directory_domain_name}\\${local.admin_username}",
    Restart = "true",
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = local.admin_password
  })
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsau6ec3"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_virtual_machine_group" "test" {
  name                = "acctestgr-u6ec3"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sql_image_offer     = "SQL2019-WS2019"
  sql_image_sku       = "Developer"

  wsfc_domain_profile {
    fqdn = local.active_directory_domain_name

    cluster_bootstrap_account_name = "${local.admin_username}@${local.active_directory_domain_name}"
    cluster_operator_account_name  = "${local.admin_username}@${local.active_directory_domain_name}"
    sql_service_account_name       = "${local.admin_username}@${local.active_directory_domain_name}"
    storage_account_url            = azurerm_storage_account.test.primary_blob_endpoint
    storage_account_primary_key    = azurerm_storage_account.test.primary_access_key
    cluster_subnet_type            = "SingleSubnet"
  }
}


resource "azurerm_mssql_virtual_machine" "test" {
  virtual_machine_id           = azurerm_windows_virtual_machine.client.id
  sql_license_type             = "PAYG"
  sql_virtual_machine_group_id = azurerm_mssql_virtual_machine_group.test.id

  wsfc_domain_credential {
    cluster_bootstrap_account_password = local.admin_password
    cluster_operator_account_password  = local.admin_password
    sql_service_account_password       = local.admin_password
  }

  depends_on = [
    azurerm_virtual_machine_extension.join_domain
  ]
}
