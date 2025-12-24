class Toonrb::GeneratedParser
token QUOTED_STRING UNQUOTED_STRING BOOLEAN NULL NUMBER

rule
  root_objects
    |
    | root_objects root_object
    ;
  root_object
    | primitive {
        @handler.push_child(val[0])
      }
    ;
  primitive
    | QUOTED_STRING {
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
