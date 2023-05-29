# https://hexdocs.pm/elixir

cd First_project_text_to_json

elixirc elixir_test_1.exs | tee log_1.txt ; echo ''

cd ..

# Second_project_json_to_groupBY
# min new groupby

cd groupby
mix deps.get
mix compile

mix run | tee log_2.txt ; echo ''

cd ..
