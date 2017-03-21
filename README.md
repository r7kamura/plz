# Plz
JSON Schema based command line HTTP client.

![screenshot](images/screenshot.png)

### Install
```sh
$ gem install plz
```

### Synopsis
```sh
$ plz <action> <target> [headers|params] [options]
         |        |         |      |       |
         |        |         |      |       `-- --no-response-header
         |        |         |      |           --no-response-body
         |        |         |      |           --no-color
         |        |         |      |           --help, -h
         |        |         |      |
         |        |         |      `---------- key=value | key:=value | key=:value
         |        |         |
         |        |         `----------------- Key:value
         |        |
         |        `--------------------------- target name
         |
         `------------------------------------ action name
```

### Schema
To use Plz, you need to have a JSON Schema file at `./schema.json` or `./schema.yaml`,
that describes about the API where you want to send HTTP request.
Plz interprets command-line arguments based on that JSON Schema, then sends HTTP request.
See [schema.yml](schema.yml) as an example.

### Headers
To set custom request headers you can use `Key:value` syntax in command line argument.

```sh
$ plz list user Api-Access-Token:123
```

### Params
Params are used for the following purpose:

* URI Template variables
* Query string in GET method
* Request body in other methods

You can set params by `key=value`, `key:=value`, or `key=:value` syntax in command line arguments.
`key:=value` is parsed into a JSON value (e.g. key:=17 will be `{"key":17}`),
while `key=:value` is parsed into a String value.
`key=value` will try to parse into a JSON value, and fall back to a String value.

```sh
$ plz create user name=alice age:=17 birthday=:2000-02-24
```

As a special case, if the first argument after the target is not a header or param assignment,
it will be treated like `target=argument`, i.e. assign the argument to a parameter named after the target.

### Stdin
You can pass params via STDIN, instead of command line arguments.

```sh
$ plz create user < params.json
$ cat params.json | plz create user
```

### Options
Plz takes some command line options.

```sh
$ plz --help
Usage: plz <action> <target> [headers|params] [options]
    -h, --help                    Display help message
        --help-all                Display help message with all examples
    -s, --schema                  Schema file or URL
    -H, --host                    API host
        --no-color                Disable coloring output
        --no-response-body        Hide response body
        --no-response-header      Hide response header
Examples:
  plz list user
  plz create user
  plz update user id=1
  plz delete user id=1
```

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
