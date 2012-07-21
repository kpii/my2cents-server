When /^"([^\"]*)" posts the following comment$/ do |user_name, table|
  user = User.find_by_name!(user_name)
  table.hashes.each do |row|
    Comment.create!(row.merge(:user => user))
  end
end
