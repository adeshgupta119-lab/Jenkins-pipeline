# terraform-1980-infra — Axion project

Azure infra for the Axion project: resource group, storage account, key
vault, VNet with 3 subnets (frontend/backend/database), NSGs, public IP,
and 3 Linux VMs (free-tier `Standard_B1s`), one per subnet.

## Folder structure

```
terraform-1980-infra/
├── environments/
│   ├── preprod/     → main.tf, provider.tf, variables.tf, terraform.tfvars
│   └── prod/         → (placeholder, reuses the same modules later)
├── modules/
│   ├── azurerm_resource_group/
│   ├── azurerm_virtual_network/
│   ├── azurerm_subnet/
│   ├── azurerm_network_security_group/
│   ├── azurerm_public_ip/
│   ├── azurerm_storage_account/
│   ├── azurerm_key_vault/
│   └── azurerm_virtual_machine/   (data.tf + main.tf + variables.tf)
```

## Naming convention

Every resource name is generated automatically from three inputs in
`terraform.tfvars` — `project`, `environment`, `region_code` — combined in
`environments/preprod/main.tf` as `locals.name_prefix`. Nobody has to type
resource names by hand, so there's no risk of typos or mismatched names
between modules:

| Resource | Pattern | Example |
|---|---|---|
| Resource group | `rg-<prefix>` | `rg-axion-preprod-cin` |
| VNet | `vnet-<prefix>` | `vnet-axion-preprod-cin` |
| Subnet | `snet-<prefix>-<tier>` | `snet-axion-preprod-cin-frontend` |
| NSG | `nsg-<prefix>-<tier>` | `nsg-axion-preprod-cin-backend` |
| Public IP | `pip-<prefix>-frontend` | `pip-axion-preprod-cin-frontend` |
| NIC | `nic-<prefix>-<tier>` | `nic-axion-preprod-cin-database` |
| VM | `vm-<prefix>-<tier>` | `vm-axion-preprod-cin-frontend` |
| Storage account | `st<prefix-no-hyphens><random5>` | `staxionpreprodcinab12x` |
| Key vault | `kv-<prefix>-<random5>` | `kv-axion-preprod-cin-ab12x` |

Storage account and key vault names must be **globally unique**, so a
random 5-character suffix (`random_string.suffix`) is appended
automatically. Everything else only needs to be unique within the
resource group, so no suffix is needed there.

## Network layout

Three subnets, one per tier, each with its own NSG (SSH port 22 only,
source restricted by `allowed_ssh_source` / the VNet range):

- **frontend** — gets the public IP, reachable from the internet
- **backend** — internal only, no public IP
- **database** — internal only, no public IP

This mirrors a real production pattern where only the frontend tier is
internet-facing.

## Secrets — Key Vault flow

1. `random_password.vm_admin` generates a strong password at apply time —
   nobody types or hardcodes it.
2. It's stored in Key Vault via the `azurerm_key_vault` module
   (`secrets = { "vm-admin-password" = random_password.vm_admin.result }`).
3. The VM module's `data.tf` reads it back with
   `data.azurerm_key_vault_secret.vm_password` and assigns it to
   `admin_password` on each VM.
4. The resolved value ends up in the Terraform state file, which is why
   state must live in a properly access-controlled remote backend (see
   below) rather than sitting around as a local file.

The `secrets` variable on the key vault module is marked `sensitive = true`
so its value never prints in plan/apply output.

## Data sources vs. module outputs

The VM module fetches the subnet and public IP via `data` blocks
(`data.tf`) instead of referencing `module.subnet` / `module.pips`
outputs directly — this simulates a real-world case where networking is
owned and managed by a separate team/state, and the compute team can only
look resources up by name. The NSG module, by contrast, takes the subnet
ID directly from `module.subnet` outputs, since NSG-to-subnet association
happens within the same apply here.

## Other best practices applied

- **`for_each` everywhere** (VNet, subnet, NSG, public IP, VM, NIC) instead
  of `count` — adding a new VM/subnet means adding a map entry, not
  duplicating resource blocks.
- **Explicit `depends_on`** at both the resource level (NIC waits on the
  subnet/public IP data sources, VM waits on the NIC) and the module level
  (`subnet` waits on `vnet`, `vms` waits on `subnet` + `pips` + `nsg` +
  `keyvault`).
- **Variable validation** — `environment` must be one of `dev/preprod/prod`;
  `vm_size` must be a free-tier eligible size.
- **`lifecycle { prevent_destroy = true }`** on the storage account, so an
  accidental `terraform destroy` can't silently wipe it. Remove this if you
  actually intend to tear the environment down.
- **`lifecycle { ignore_changes = [tags] }`** on the VMs, so out-of-band tag
  edits in the portal don't get reverted on the next apply.
- **`boot_diagnostics`** enabled on every VM for troubleshooting boot
  issues.

## Remote backend (not yet enabled)

`provider.tf` has a commented `backend "azurerm"` block. A remote backend
needs its target storage account to already exist, so it can't bootstrap
itself — create that storage account once (manually or via a small
separate bootstrap config), then uncomment the block and run
`terraform init -migrate-state`.

## Usage

```bash
cd environments/preprod
# edit terraform.tfvars: set allowed_ssh_source to your real IP
terraform init
terraform validate
terraform plan
terraform apply
```

## Not yet covered

- CI/CD pipeline (skipped per request — add later if needed)
- `prod` environment (folder exists, empty — copy the same pattern from
  `preprod` when ready, with its own `terraform.tfvars`)
