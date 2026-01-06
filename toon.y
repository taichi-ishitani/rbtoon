class Toonrb::GeneratedParser
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
      }
  object_head_item
    : object_head_key COLON object_value
    | object_head_key array
  object_head_key
    : string {
        handler.push_object(val[0])
      }
  object_item
    : object_key COLON object_value
    | object_key array
  object_key
    : string {
        handler.push_value(val[0], key: true)
      }
  object_value
    : NL BLANK? {
        position = scanner.current_position
        handler.push_empty_object(position)
      }
    | primitive NL BLANK? {
        handler.push_value(val[0])
      }
    | array
    | NL BLANK? PUSH_INDENT object POP_INDENT

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
        scanner.start_array
      }
  inline_array
    : array_header_common COLON inline_array_values NL BLANK? {
        handler.pop
        scanner.end_array
      }
  inline_array_values
    : inline_array_value (DELIMITER inline_array_value)* {
        each_list_item(val) { |v, _| handler.push_value(v) }
      }
  inline_array_value
    : primitive
    | empty_string
  list_array
    : list_array_header {
        handler.pop
        scanner.end_array
      }
    | list_array_header PUSH_INDENT list_array_items POP_INDENT {
        handler.pop
        scanner.end_list_array_items
        scanner.end_array
    }
  list_array_header
    : array_header_common COLON NL BLANK?
  list_array_items
    : list_array_start list_array_value (HYPHEN list_array_value)*
  list_array_start
    : HYPHEN {
        scanner.start_list_array_items
      }
  list_array_value
    : NL BLANK? {
        handler.push_empty_object(val[0])
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
        scanner.end_array
      }
    | tebular_array_header PUSH_INDENT tabular_row+ POP_INDENT {
        handler.pop
        scanner.end_array
      }
  tebular_array_header
    : array_header_common L_BRACE tabular_fields R_BRACE COLON NL BLANK?
  tabular_fields
    : string (DELIMITER string)* {
        each_list_item(val) { |v, _| handler.push_value(v, tabular_field: true) }
      }
  tabular_row
    : tabular_row_value (DELIMITER tabular_row_value)* NL BLANK? {
        each_list_item(val) do |v, i|
          handler.push_value(v, tabular_value: true, head_value: i.zero?)
        end
        handler.push_blank(val[3], tabular_value: true, head_value: true)
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
