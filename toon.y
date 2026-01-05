class GeneratedParser
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
    : NL {
        position = scanner.current_position
        handler.push_empty_object(position)
      }
    | primitive NL {
        handler.push_value(val[0])
      }
    | array
    | NL PUSH_INDENT object POP_INDENT

  array
    : array_header NL {
        handler.pop
        scanner.end_array
      }
    | array_header inline_array_values NL {
        handler.pop
        scanner.end_array
      }
    | array_header NL PUSH_INDENT list_array_items POP_INDENT {
        handler.pop
        scanner.end_list_array_items
        scanner.end_array
      }
    | tebular_array_header NL {
        handler.pop
        scanner.end_array
      }
    | tebular_array_header NL PUSH_INDENT tabular_rows POP_INDENT {
        handler.pop
        scanner.end_array
      }
  array_header
    : array_header_common COLON
  tebular_array_header
    : array_header_common L_BRACE tabular_fields R_BRACE COLON
  array_header_common
    : array_header_start number DELIMITER? R_BRACKET {
        scanner.delimiter(val[2])
        handler.push_array(val[0], val[1])
      }
  array_header_start
    : L_BRACKET {
        scanner.start_array
      }
  tabular_fields
    : string (DELIMITER string)* {
        each_list_item(val) { |v, _| handler.push_value(v, tabular_field: true) }
      }
  inline_array_values
    : primitive (DELIMITER primitive)* {
        each_list_item(val) { |v, _| handler.push_value(v) }
      }
  list_array_items
    : (list_array_start_item list_array_blank?) (list_array_item list_array_blank?)*
  list_array_start_item
    : list_array_items_start list_array_value
  list_array_items_start
    : HYPHEN {
        scanner.start_list_array_items
      }
  list_array_item
    : HYPHEN list_array_value
  list_array_value
    : NL {
        position = scanner.current_position
        handler.push_empty_object(position)
      }
    | primitive NL {
        handler.push_value(val[0])
      }
    | array
    | object
  list_array_blank
    : blank {
        handler.push_value(val[0])
      }
  tabular_rows
    : (tabular_row tabular_blank?)+
  tabular_row
    : tabular_row_value (DELIMITER tabular_row_value)* NL {
        each_list_item(val) do |v, i|
          handler.push_value(v, tabular_value: true, head_value: i.zero?)
        end
      }
  tabular_row_value
    : primitive
  tabular_blank
    : blank {
        handler.push_value(val[0], tabular_value: true, head_value: true)
      }

  primitive
    : string
    | boolean
    | null
    | number
  string
    : QUOTED_STRING {
        result = Toonrb::Nodes::QuotedString.new(val[0])
      }
    | UNQUOTED_STRING {
        result = Toonrb::Nodes::UnquotedString.new(val[0])
      }
  boolean
    : BOOLEAN {
        result = Toonrb::Nodes::Boolean.new(val[0])
      }
  null
    : NULL {
        result = Toonrb::Nodes::Null.new(val[0])
      }
  number
    : NUMBER {
        result = Toonrb::Nodes::Number.new(val[0])
      }
  blank
    : BLANK {
        result = Toonrb::Nodes::Blank.new(val[0])
      }
