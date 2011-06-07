Series.blueprint do
  moviemaster_id      { Sham.moviemaster_id }
  title               { Sham.title }
end

Category.blueprint do
  name               { "Category#{sn}" }
end
