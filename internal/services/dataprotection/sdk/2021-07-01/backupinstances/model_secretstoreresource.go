package backupinstances

type SecretStoreResource struct {
	SecretStoreType SecretStoreType `json:"secretStoreType"`
	Uri             *string         `json:"uri,omitempty"`
}
