# 0.9.0

 - ResemblesBoolean doesn't care about the value of the boolean, only that it
   is a boolean.
 - ResemblesAnyOf with non-homogeneous arrays no longer prints errors when the
   overall array matched successfully.

# 0.8.0

 - ResemblesJson now fails if there are unexpected keys in the actual hash

# 0.7.3

 - Add a few more missing render methods
 - Only try to call indifferent_access on Hashes

# 0.7.2

 - Expose `expected` in the nil matcher so the description can be rendered

# 0.7.1

 - Handle rendering when matcher value is null

# 0.7.0

 - Change the output to be a diff-like view rather than verbose prose

# 0.5.2

 - Fix an error that was included in master by mistake

# 0.5.1 (yanked)

 - Add support for Rails 3.2 by monkey-patching String#index if it's not already

