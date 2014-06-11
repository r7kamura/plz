# Plz
JSON Schema based cURL-like tool.

```sh
$ plz list user
[
  {
    "id": 1,
    "name": "alice"
  },
]

$ plz show user id=1
{
  "id": 1,
  "title": "alice"
}

$ plz create user name=bob
{
  "id": 2
  "name": "bob"
}
```

## Install
```sh
$ gem install plz
```
