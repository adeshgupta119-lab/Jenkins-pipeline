resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  name_prefix = "${var.project}-${var.environment}-${var.region_code}"

  resource_group_name  = "rg-${local.name_prefix}"
  storage_account_name = "st${replace(local.name_prefix, "-", "")}${random_string.suffix.result}"
  key_vault_name       = "kv-${var.project}-${random_string.suffix.result}"
  vnet_name            = "vnet-${local.name_prefix}"

  vnets = {
    main = {
      name                = local.vnet_name
      address_space       = var.vnet_address_space
      location            = var.location
      resource_group_name = local.resource_group_name
      tags                = var.tags
    }
  }

  subnets = {
    frontend = {
      name                 = "snet-${local.name_prefix}-frontend"
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      address_prefixes     = var.subnet_prefixes.frontend
    }
    backend = {
      name                 = "snet-${local.name_prefix}-backend"
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      address_prefixes     = var.subnet_prefixes.backend
    }
    database = {
      name                 = "snet-${local.name_prefix}-database"
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      address_prefixes     = var.subnet_prefixes.database
    }
  }

  public_ips = {
    frontend = {
      name                = "pip-${local.name_prefix}-frontend"
      resource_group_name = local.resource_group_name
      location            = var.location
    }
  }

  nsgs = {
    frontend = {
      nsg_name            = "nsg-${local.name_prefix}-frontend"
      location            = var.location
      resource_group_name = local.resource_group_name
      subnet_id           = module.subnet.subnet_ids["frontend"]
      allowed_ssh_source  = var.allowed_ssh_source
    }
    backend = {
      nsg_name            = "nsg-${local.name_prefix}-backend"
      location            = var.location
      resource_group_name = local.resource_group_name
      subnet_id           = module.subnet.subnet_ids["backend"]
      allowed_ssh_source  = var.vnet_address_space[0]
    }
    database = {
      nsg_name            = "nsg-${local.name_prefix}-database"
      location            = var.location
      resource_group_name = local.resource_group_name
      subnet_id           = module.subnet.subnet_ids["database"]
      allowed_ssh_source  = var.vnet_address_space[0]
    }
  }

  virtual_machines = {
    frontend = {
      vm_name              = "vm-${local.name_prefix}-frontend"
      nic_name             = "nic-${local.name_prefix}-frontend"
      location             = var.location
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      subnet_name          = "snet-${local.name_prefix}-frontend"
      public_ip_name       = "pip-${local.name_prefix}-frontend"
      vm_size              = var.vm_size
      admin_username       = var.admin_username
      tags                 = var.tags
    }
    backend = {
      vm_name              = "vm-${local.name_prefix}-backend"
      nic_name             = "nic-${local.name_prefix}-backend"
      location             = var.location
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      subnet_name          = "snet-${local.name_prefix}-backend"
      public_ip_name       = null
      vm_size              = var.vm_size
      admin_username       = var.admin_username
      tags                 = var.tags
    }
    database = {
      vm_name              = "vm-${local.name_prefix}-database"
      nic_name             = "nic-${local.name_prefix}-database"
      location             = var.location
      resource_group_name  = local.resource_group_name
      virtual_network_name = local.vnet_name
      subnet_name          = "snet-${local.name_prefix}-database"
      public_ip_name       = null
      vm_size              = var.vm_size
      admin_username       = var.admin_username
      tags                 = var.tags
    }
  }
}

module "rg" {
  source = "../../modules/azurerm_resource_group"

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "vnet" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_virtual_network"

  vnets = local.vnets
}

module "subnet" {
  depends_on = [module.vnet]
  source     = "../../modules/azurerm_subnet"

  subnets = local.subnets
}

module "nsg" {
  depends_on = [module.subnet]
  source     = "../../modules/azurerm_network_security_group"

  subnets = local.nsgs
}

module "pips" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_public_ip"

  public_ips = local.public_ips
}

module "storage" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_storage_account"

  storage_account_name = local.storage_account_name
  resource_group_name  = local.resource_group_name
  location             = var.location
  tags                 = var.tags
}

module "keyvault" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_key_vault"

  key_vault_name      = local.key_vault_name
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  secrets = {
    "vm-ssh-public-key" = var.ssh_public_key
  }
}

module "vms" {
  depends_on = [module.subnet, module.pips, module.nsg, module.keyvault]
  source     = "../../modules/azurerm_virtual_machine"

  virtual_machines    = local.virtual_machines
  key_vault_name      = local.key_vault_name
  resource_group_name = local.resource_group_name
}
