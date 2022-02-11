package backupvaults

type StorageSetting struct {
	DatastoreType *StorageSettingStoreTypes `json:"datastoreType,omitempty"`
	Type          *StorageSettingTypes      `json:"type,omitempty"`
}
