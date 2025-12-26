class Toonrb::GeneratedParser
token
  L_BRACKET
  R_BRACKET
  COLON
  DELIMITER
  QUOTED_STRING
  UNQUOTED_STRING
  BOOLEAN
  NULL
  NUMBER

rule
  root
    :
    | root root_item {
        @root.items << val[1]
      }
    ;
  root_item
    : inline_array
    | primitive
    ;

  inline_array
    : array_header inline_array_values {
      header = val[0]
      values = val[1]
      result = Nodes::Array.new(header[0], header[1], values)
    }
  array_header
    : L_BRACKET NUMBER delimiter R_BRACKET COLON {
        result = val
      }
  delimiter
    : {
        @scanner.push_delimiter(',')
      }
    | DELIMITER {
        @scanner.push_delimiter(val[0].text)
      }
    ;
  inline_array_values
    :
    | primitive {
        result = [val[0]]
      }
    | inline_array_values DELIMITER primitive {
        result << val[2]
      }
    ;

  primitive
    : QUOTED_STRING {
        result = Toonrb::Nodes::QuotedString.new(val[0])
      }
    | UNQUOTED_STRING {
        result = Toonrb::Nodes::UnquotedString.new(val[0])
    }
    | BOOLEAN {
        result = Toonrb::Nodes::Boolean.new(val[0])
      }
    | NULL {
        result = Toonrb::Nodes::Null.new(val[0])
      }
    | NUMBER {
        result = Toonrb::Nodes::Number.new(val[0])
      }
    ;
