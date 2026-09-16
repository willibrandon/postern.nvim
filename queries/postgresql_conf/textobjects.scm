(setting) @assignment.outer

(setting
  name: (_) @assignment.lhs
  value: (_) @assignment.rhs @assignment.inner)

(hba_rule) @statement.outer

(user_mapping) @statement.outer

(auth_option) @parameter.outer

(comment) @comment.outer
