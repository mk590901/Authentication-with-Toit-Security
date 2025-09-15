import .storage_utils

main :
  
  remove_scope_storage  "tokens"
  remove_scope_secret   "uri_auth"
  remove_scope_secret   "uri_refresh"
  remove_scope_secret   "uri_db"
  remove_scope_secret   "api_key"
