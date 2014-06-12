# Plz
JSON Schema based command line HTTP client.

## Usage
![screenshot](images/screenshot.png)

### Install
```sh
$ gem install plz
```

### Synopsis
```sh
$ plz <action> <target> [headers|params]
         |        |         |      |
         |        |         |      `---- key=value ({"key":"value"}) or key:=value ({"key":value})
         |        |         |            params can be:
         |        |         |            * URI Template variable
         |        |         |            * Query string in GET method
         |        |         |            * Request body in other methods
         |        |         |
         |        |         `----------- Key:value
         |        |
         |        `--------------------- target resource name (e.g. user, recipe, etc.)
         |
         `------------------------------ action name (e.g. show, list, create, delete, etc.)
```

### Schema
To use Plz, you need to have a JSON Schema file at `./schema.json` or `./schema.yaml`,
that describes about the API where you want to send HTTP request.
Plz interprets command-line arguments based on that JSON Schema, then sends HTTP request.

### Example
```sh
# GET /users
$ plz list user
[
  {
    "id": 1,
    "name": "alice"
  },
  {
    "id": 2,
    "name": "bob"
  }
]

# GET /users/2
$ plz show user id=2
{
  "id": 2,
  "name": "bob"
}

# POST /users with {"name":"charlie"} params
$ plz create user name=charlie
{
  "id": 3,
  "name": "charlie"
}

# POST /users with {"name":"dave",age:20} params
$ plz create user name=dave age:=20
{
  "id": 4,
  "age":20
  "name": "dave"
}

# POST /users with Api-Access-Token:123 header and {"name":"ellen"} params
$ plz create user name=ellen Api-Access-Token:123
{
  "id": 5,
  "name": "ellen"
}
```
