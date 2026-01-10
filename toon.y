class RbToon::GeneratedParser
token
  L_BRACKET
  R_BRACKET
  L_BRACE
  R_BRACE
  COLON
  HYPHEN
  DELIMITER
  QUOTED_STRING
  UNQUOTED_STRING
  BOOLEAN
  NULL
  NUMBER
  NL
  PUSH_INDENT
  POP_INDENT
  BLANK
  EOS

rule
  root
    : root_item* EOS
  root_item
    : NL
    | BLANK
    | object
    | array
    | primitive NL {
        handler.push_value(val[0])
      }

  object
    : object_head_item object_item* {
        handler.pop
        scanner.pop_object
      }
  object_head_item
    : object_head_key COLON object_value
    | object_head_key array
  object_head_key
    : string {
        handler.push_object(val[0])
        scanner.push_object
      }
  object_item
    : object_key COLON object_value
    | object_key array
  object_key
    : string {
        handler.push_value(val[0])
      }
  object_value
    : NL BLANK? {
        handler.push_empty_object(val[0].position)
        handler.push_blank(val[1])
      }
    | primitive NL BLANK? {
        handler.push_value(val[0])
        handler.push_blank(val[2])
      }
    | array
    | nl_blank PUSH_INDENT object POP_INDENT

  array
    : inline_array
    | list_array
    | tebular_array
  array_header_common
    : array_header_start number DELIMITER? R_BRACKET {
        scanner.delimiter(val[2])
        handler.push_array(val[0], val[1])
      }
  array_header_start
    : L_BRACKET {
        scanner.push_array
      }
  inline_array
    : array_header_common COLON inline_array_values nl_blank {
        handler.pop
        scanner.pop_array
      }
  inline_array_values
    : inline_array_value (DELIMITER inline_array_value)* {
        handler.push_values(to_list(val))
      }
  inline_array_value
    : primitive
    | empty_string
  list_array
    : list_array_header {
        handler.pop
        scanner.pop_array
      }
    | list_array_header PUSH_INDENT list_array_items POP_INDENT {
        handler.pop
        scanner.pop_array
    }
  list_array_header
    : array_header_common COLON nl_blank
  list_array_items
    : list_array_start list_array_value (HYPHEN list_array_value)*
  list_array_start
    : HYPHEN {
        scanner.start_list_array_items
      }
  list_array_value
    : NL BLANK? {
        handler.push_empty_object(val[0].position)
        handler.push_blank(val[1])
      }
    | primitive NL BLANK? {
        handler.push_value(val[0])
        handler.push_blank(val[2])
      }
    | array
    | object
  tebular_array
    : tebular_array_header {
        handler.pop
        scanner.pop_array
      }
    | tebular_array_header PUSH_INDENT tabular_rows POP_INDENT {
        handler.pop
        scanner.pop_array
      }
  tebular_array_header
    : array_header_common L_BRACE tabular_fields R_BRACE COLON nl_blank
  tabular_fields
    : string (DELIMITER string)* {
        handler.push_tabular_fields(to_list(val))
      }
  tabular_rows
    : (tabular_row nl_blank)+
  tabular_row
    : tabular_row_value (DELIMITER tabular_row_value)* {
        handler.push_tabular_row(to_list(val))
      }
  tabular_row_value
    : primitive
    | empty_string

  primitive
    : string
    | boolean
    | null
    | number
  string
    : QUOTED_STRING {
        result = handler.quoted_string(val[0])
      }
    | UNQUOTED_STRING {
        result = handler.unquoted_string(val[0])
      }
  empty_string
    : {
        position = scanner.current_position
        result = handler.empty_string(position)
      }
  boolean
    : BOOLEAN {
        result = handler.boolean(val[0])
      }
  null
    : NULL {
        result = handler.null(val[0])
      }
  number
    : NUMBER {
        result = handler.number(val[0])
      }

  nl_blank
    : NL BLANK? {
        handler.push_blank(val[1])
      }
