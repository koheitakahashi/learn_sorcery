ActiveRecord::Base.translations do
  user = User.create!(
    email: 'otegami@example.com',
    password: 'password',
    password_confirmation: 'password'
  )

  user.activate!

  user.books.create!(title: "ドメイン駆動開発", description: "ドメイン駆動開発について書かれた本")
end

puts "作成がおわったよ"
