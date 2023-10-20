
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231020041948021441"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctbdzgq"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
                                    t0 = "v0"
t1 = "v1"
t2 = "v2"
t3 = "v3"
t4 = "v4"
t5 = "v5"
t6 = "v6"
t7 = "v7"
t8 = "v8"
t9 = "v9"
t10 = "v10"
t11 = "v11"
t12 = "v12"
t13 = "v13"
t14 = "v14"
t15 = "v15"
t16 = "v16"
t17 = "v17"
t18 = "v18"
t19 = "v19"
t20 = "v20"
t21 = "v21"
t22 = "v22"
t23 = "v23"
t24 = "v24"
t25 = "v25"
t26 = "v26"
t27 = "v27"
t28 = "v28"
t29 = "v29"
t30 = "v30"
t31 = "v31"
t32 = "v32"
t33 = "v33"
t34 = "v34"
t35 = "v35"
t36 = "v36"
t37 = "v37"
t38 = "v38"
t39 = "v39"
t40 = "v40"
t41 = "v41"
t42 = "v42"
t43 = "v43"
t44 = "v44"
t45 = "v45"
t46 = "v46"
t47 = "v47"
t48 = "v48"
t49 = "v49"

  }
}
