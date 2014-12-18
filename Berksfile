site :opscode

group :integration do
  cookbook 'minitest-handler'
  cookbook 'java', '>= 1.21.2'
  cookbook 'krb5_utils', github: 'caskdata/krb5_utils_cookbook'
end

cookbook 'krb5', github: 'atomic-penguin/cookbook-krb5', ref: 'feature/lwrp-replace-utils-cookbook'

metadata
