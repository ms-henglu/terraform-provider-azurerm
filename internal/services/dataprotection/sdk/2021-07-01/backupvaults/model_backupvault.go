package backupvaults

type BackupVault struct {
	ProvisioningState   *ProvisioningState   `json:"provisioningState,omitempty"`
	ResourceMoveDetails *ResourceMoveDetails `json:"resourceMoveDetails,omitempty"`
	ResourceMoveState   *ResourceMoveState   `json:"resourceMoveState,omitempty"`
	StorageSettings     []StorageSetting     `json:"storageSettings"`
}
