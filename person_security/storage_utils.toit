import system.storage

load_tokens -> Map? :

  result/Map? := null

  error := false
  try :

    e := catch --trace=false :

      bucket_ := storage.Bucket.open --flash "storage"
      tokens_ := bucket_["tokens"]
      id_token_/string := tokens_["id_token"]
      refresh_token_/string := tokens_["refresh_token"]
      result = { "id_token" : id_token_, "refresh_token" : refresh_token_ }

    if e :
      error = true
      print "Exception -> $e"  

  finally :

    return result

save_tokens id_token/string? refresh_token/string? -> bool :

  result/bool := false

  if id_token == null or refresh_token == null :
    print "Failed to save nullable tokens"
    return result

  error := false
  
  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "storage"
      bucket["tokens"] = { "id_token" : id_token, "refresh_token" : refresh_token }
      result = true

    if e :
      error = true
      print "Exception -> $e"  

  finally :

    return result

remove_scope_storage key/string -> bool :

  result/bool := false

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "storage"
      bucket.remove key
      result = true

    if e :
      print "Exception -> $e"  

  finally :

    return result

remove_scope_secret key/string -> bool :

  result/bool := false

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "secret"
      bucket.remove key
      result = true

    if e :
      print "Exception -> $e"  

  finally :

    return result


save_api_key api_key/string -> bool :

  result/bool := false

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "secret"
      bucket["api_key"] = api_key
      result = true

    if e :
      print "save_api_key.exception -> $e"  

  finally :

    return result

save_path key/string path/string-> bool :

  result/bool := false

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "secret"
      bucket[key] = path
      result = true

    if e :
      print "save($key).exception -> $e"  

  finally :

    return result

load_path key/string -> string? :

  path/string? := null

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "secret"
      path = bucket[key]

    if e :
      print "load($key).exception -> $e"  

  finally :

    return path

save_uri_auth api_key/string -> bool :
  return save_path "uri_auth" "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$api_key"

save_uri_db -> bool :
  return save_path "uri_db" "XXXXXXX"

save_uri_refresh api_key/string -> bool :
  return save_path "uri_refresh" "https://securetoken.googleapis.com/v1/token?key=$api_key"

load_uri_auth -> string? :
  return load_path "uri_auth"

load_uri_db -> string? :
  return load_path "uri_db"

load_uri_refresh -> string? :
  return load_path "uri_refresh"

load_api_key -> string? :

  result/string? := null

  try :

    e := catch --trace=false :

      bucket := storage.Bucket.open --flash "secret"
      result = bucket["api_key"]

    if e :
      print "load_api_key.exception -> $e"  

  finally :

    return result




