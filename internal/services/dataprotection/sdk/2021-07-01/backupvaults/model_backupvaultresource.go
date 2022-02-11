package backupvaults

type BackupVaultResource struct {
	ETag       *string             `json:"eTag,omitempty"`
	Id         *string             `json:"id,omitempty"`
	Identity   *DppIdentityDetails `json:"identity,omitempty"`
	Location   string              `json:"location"`
	Name       *string             `json:"name,omitempty"`
	Properties BackupVault         `json:"properties"`
	SystemData *SystemData         `json:"systemData,omitempty"`
	Tags       *map[string]string  `json:"tags,omitempty"`
	Type       *string             `json:"type,omitempty"`
}
