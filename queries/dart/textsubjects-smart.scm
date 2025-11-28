;; extends
(
  ([
    (local_variable_declaration)
    (const_object_expression)
    (return_statement)
    (try_statement)
    (conditional_expression)
    (local_function_declaration)
    (if_statement)
    (formal_parameter)
    (initializers)
    (initializer_list_entry)
  ]) @_start
  (#make-range! "range" @_start @_start)
)

(
  (named_argument) @_start
  .
  "," @_end
  (#make-range! "range" @_start @_end)
)

(
  (named_argument) @_start
  .
  ")"
  (#make-range! "range" @_start @_start)
)

(
  ([
    (declaration)
    (assignment_expression)
  ]) @_start
  .
  ";" @_end
  (#make-range! "range" @_start @_end)
)

(
  (identifier) @_start
  .
  (selector
    ([
      (unconditional_assignable_selector)
      (argument_part)
    ])
  )+ @_end
  .
  (#make-range! "range" @_start @_end)
)

(
  (identifier) @_start
  .
  (selector
    ([
      (unconditional_assignable_selector)
      (argument_part)
    ])
  ) @_end
  ";"
  (#make-range! "range" @_start @_end)
)


(
  (selector
    ([
      (unconditional_assignable_selector)
      (argument_part)
    ])
  ) @_start
  .
  (selector
    ([
      (unconditional_assignable_selector)
      (argument_part)
    ])
  )* @_end
  (#make-range! "range" @_start @_end)
)


(
  (method_signature) @_start
  .
  (function_body) @_end
  (#make-range! "range" @_start @_end)
)

(
  (annotation) @_start
  .
  (method_signature)
  .
  (function_body) @_end
  (#make-range! "range" @_start @_end)
)

; Flutter widget
(
  (identifier) @_start
  .
  (selector
    (argument_part)
  ) @_end
  (#make-range! "range" @_start @_end)
)
