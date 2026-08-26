(comment) @subject

[
  (class_definition)
  (enum_declaration)
  (mixin_declaration)
  (extension_declaration)
  (if_statement)
  (for_statement)
  (while_statement)
  (do_statement)
  (switch_statement)
  (try_statement)
  (return_statement)
  (expression_statement)
  (assert_statement)
  (local_variable_declaration)
] @subject.linewise

[
  (list_literal)
  (set_or_map_literal)
] @subject

(arguments (_) @subject)
(formal_parameter_list (_) @subject)

; The RHS of `final x = below.message.senderId` is split across N `value:`
; field children (identifier + one selector per chain segment). Span them all
; into a single subject so the whole chain selects as one unit.
((initialized_variable_definition) @_decl
  (#span-field-children! "subject" @_decl "value"))
