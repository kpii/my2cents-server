Then /^I should see the image "([^\"]*)"$/ do |src|
  page.body.should have_tag("img[src=?]", src)
end

Then /^I should see the image "([^\"]*)" within "([^\"]*)"$/ do |src, selector|
  page.body.should have_tag("#{selector} img[src=?]", src)
end
