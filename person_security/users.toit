import http
import net
import encoding.json
import certificate-roots
import .storage_utils

URI_AUTH    := load_uri_auth
URI_DB      := load_uri_db
URI_REFRESH := load_uri_refresh

OK          := 200
UNAUTHORIZED:= 401 

id_token/string?      := null
refresh_token/string? := null

//  Obtaining ID Token and Refresh Token via
//  Anonymous Authentication

get_tokens -> Map? :

  result/Map? := null

  headers := http.Headers
  headers.set "Content-Type" "application/json"
  
  jsonObject := json.encode {"returnSecureToken": true}

  network := net.open
  client := http.Client network

  try:
    
    print "Obtaining ID Token and Refresh Token ..."

    e := catch --trace=false :

      response := client.post --uri=URI_AUTH --headers=headers jsonObject
      data := json.decode-stream response.body
      if response.status_code == OK :
        print "Tokens successfully received"
        result = {
          "id_token"      : data["idToken"],
          "refresh_token" : data["refreshToken"]
        }
      else:
        print "Authentication error->$(response.status_code) - $(data)"
  
    if e :
      print "Exception while getting tokens->$e"

  finally:
    client.close
    network.close

    return result

// Updating ID Token using Refresh Token
refresh_id_token refresh_token/string? -> Map? :
  if not refresh_token:
    return null

  result/Map? := null

  headers := http.Headers
  headers.set "Content-Type" "application/json"

  body := json.encode {
    "grant_type": "refresh_token",
    "refresh_token": refresh_token
  }

  network := net.open
  client := http.Client network

  try:
    print "ID Token Update ..."
    e := catch --trace=false :
      response := client.post --uri=URI_REFRESH --headers=headers body
      data := json.decode-stream response.body

      if response.status_code == OK :

        print "Token successfully updated"

        new_token         := data["access_token"]
        new_refresh_token := data["refresh_token"]

        result = {
          "id_token"      : new_token,
          "refresh_token" : new_refresh_token
        }
        print "new_tokens->$result"
      else:
        print "Error refresh token->$(response.status_code) - $(data)"
    
    if e :
      print "Exception updating token->$e"
  
  finally:
    client.close
    network.close

    return result

//  Adding a record to Firebase Realtime Database
//  with retry when token expires
create_user name/string surname/string email/string phone/string age/int -> none:
  if not id_token:
    print "Invalid token, failed to create user"
    return

  user_data := {

    "name"    : name,
    "surname" : surname,
    "e-mail"  : email,
    "phone"   : phone,
    "age"     : age

  }

  network := net.open
  client := http.Client network

  try :

    headers := http.Headers
    headers.set "Content-Type" "application/json"
    body := json.encode user_data
    print "Sending a POST request to $URI_DB"

    e := catch --trace=false :

      response := client.post --uri="$URI_DB?auth=$id_token" --headers=headers body
      data := json.decode-stream response.body

      if response.status_code == OK :
        print "User was created $(data)"
      else if response.status_code == UNAUTHORIZED :  // token expired (unauthorized)
        print "Token expired, trying to update ..."
        new_tokens := refresh_id_token refresh_token
        if new_tokens :
          new_id_token := new_tokens["id_token"]
          new_refresh_token := new_tokens.get "refresh_token"

          if new_refresh_token :
            print "Tokens were updated"
            id_token = new_id_token
            refresh_token = new_refresh_token
            save_tokens id_token refresh_token
            print "*** (2) Save tokens"

        // Repeat the request with a new token
          response = client.post --uri="$URI_DB?auth=$new_id_token" --headers=headers body
          data = json.decode-stream response.body
          if response.status_code == OK :
            print "User successfully created after token refresh->$(data)"
          else:
            print "Error after token update->$(response.status_code) - $(data)"
        else:
          print "Failed to update token"
      else:
        print "Error creating user->$(response.status_code) - $(data)"
    if e :
      print "Exception creating user: $e"
  finally :
    client.close
    network.close

main:

  certificate-roots.install-common-trusted-roots

  tokens/Map? := load_tokens
  if tokens :
    id_token = tokens["id_token"]
    refresh_token = tokens["refresh_token"]
    print "*** (S) id_token->\n$id_token\n*** (S) refresh_token->\n$refresh_token"

    add_users

  else :
    tokens = get_tokens
    if tokens :
      id_token = tokens["id_token"]
      refresh_token = tokens["refresh_token"]
      save_tokens id_token refresh_token
      print "*** (1) Save tokens"
    
      print "*** (C) id_token->\n$id_token\n*** refresh_token->\n$refresh_token"

      add_users

    else:
      print "Failed to get tokens"

add_users :

  create_user "Rudolph" " Valentino" "RudolphV@gmail.com" "(800)08-123-4567" 21
  create_user "Linda" "Douglas" "LindaD@gmail.com" "(666)55-9876-5432" 33
  create_user "Harrison" " Ford" "HarrisonF@gmail.com" "(333)12-3456-7890" 45
