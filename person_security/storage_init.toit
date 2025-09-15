import .storage_utils

API_KEY := "AIzaSyB9puHJBfrFuNNoFYBHXvUQFpO6kE7W4eQ"

main :

  save_api_key      API_KEY
  save_uri_auth     API_KEY
  save_uri_db
  save_uri_refresh  API_KEY

  api_key     := load_api_key
  uri_auth    := load_uri_auth
  uri_db      := load_uri_db
  uri_refresh := load_uri_refresh

  print "api_key->\n$api_key"
  print "uri_auth->\n$uri_auth"
  print "uri_db->\n$uri_db"
  print "uri_refresh->\n$uri_refresh"


