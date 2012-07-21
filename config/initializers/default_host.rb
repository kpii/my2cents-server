DEFAULT_HOST = case Rails.env
               when 'production'
                 'my2cents.example'
               when 'development'
                 'my2cents.example:3000'
               else
                 'www.example.com'
               end
