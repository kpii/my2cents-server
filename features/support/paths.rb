module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the root\s?page/
      '/'
    
    when /^the (?:user|profile) page of "([^"]+)"/
      user = User.find_by_name($1) or raise "User #{$1} does not exist"
      "/users/#{user.id}"

    when /^the product page of "([^"]+)"/
      product = Product.find_by_name($1) or raise "Product #{$1} does not exist"
      "/products/#{product.key}"

    when "my profile page"
      locate("a.profile")['href']

    when "my inbox"
      "/inbox"

    when "the scan form"
      "/scans/new"

    # Treat anything starting with a / as URL
    when /^\//
      page_name

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
