user = User.create!(
  email: 'otegami@example.com',
  password: 'password',
  password_confirmation: 'password'
)

user.books.create!(title: "ドメイン駆動開発", description: "ドメイン駆動開発について書かれた本")

puts "作成がおわったよ"
