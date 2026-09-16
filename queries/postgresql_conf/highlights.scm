; postgresql.conf

(setting
  name: (setting_name) @property)

(string) @string

(number) @number

(unit) @type

(boolean) @boolean

(bare_value) @constant

"=" @operator

; include, include_if_exists and include_dir

(include
  [
    "include"
    "include_if_exists"
    "include_dir"
  ] @keyword.import)

(include
  path: (path) @string.special.path)

(include
  path: (string) @string.special.path)

; pg_hba.conf

(connection_type) @keyword

(name) @variable

((name) @constant.builtin
  (#any-of? @constant.builtin "all" "sameuser" "samerole" "samegroup" "replication"))

(role_group
  "+" @punctuation.special)

(file_reference
  "@" @punctuation.special
  (path) @string.special.path)

(regex) @string.regexp

(quoted_name) @string

(ip_address) @string.special

(hostname) @string.special

((hostname) @constant.builtin
  (#any-of? @constant.builtin "all" "samehost" "samenet"))

(netmask) @string.special

(auth_method) @function.builtin

(auth_option
  name: (option_name) @variable.parameter)

(auth_option
  value: (option_value) @string)

"," @punctuation.delimiter

; pg_ident.conf

(user_mapping
  map: (map_name) @type)

(system_user) @string

(database_user) @variable

(backreference) @string.special

(comment) @comment @spell
