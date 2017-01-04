defmodule KeywordFollow do

	def find_and_follow(list) do
		for item <- list, do: spawn fn -> find_and_follow(item[:to_search], item[:count]) end
	end

	def find_users(keyword, count) do
		users = []
		tweets = ExTwitter.search(keyword, count: count, result_type: :recent, lang: :en)
		users = for n <- tweets, do: String.to_integer(n.user.id_str)
		IO.puts(keyword <> ": Found " <> Integer.to_string(users) <> "to follow")
		users
	end

	def follow_users(users) do
		for user <- users, do: ExTwitter.follow(user)
	end

	def find_and_follow(string, count) do
		IO.puts("BEGAN Searching For: \"" <> string <> "\", COUNT: " <> to_string(count))
		tweets = ExTwitter.search(string, count: count, result_type: :recent, lang: :en)
		followed = 0
		for n <- tweets do 
			try do
				unless ExTwitter.follow(String.to_integer(n.user.id_str)).following == true do
				  followed = followed + 1
				end
			rescue
				ExTwitter.ConnectionError -> IO.puts "Connection Error, I have no clue why this happens"
				ExTwitter.RateLimitExceededError -> 
					IO.puts "RATE LIMIT EXCEEDED, NEED TO EXIT"
					System.halt(0)
				e in ExTwitter.Error -> IO.puts "Error, likely hit follow limit or blocked by user."
			end
			
		end
		IO.puts("FINISHED Searching For: \"" <> string <> "\", FOLLOWED: " <> to_string(followed))
	end

	def main do

		keywords = [

		  %{to_search: "KEYWORD", count: 50},
		  %{to_search: "KEYWORD2", count: 80},
		  %{to_search: "KEYWORD3", count: 60}
		]

		list_to_follow = for keyword <- keywords, do: find_users(keyword[:to_search], keyword[:count])
		list_to_follow = List.flatten(list_to_follow)

		split_to_follow = Enum.chunk(list_to_follow, 20, 20, [])
		
		for chunk <- split_to_follow  do
			spawn fn -> follow_users(chunk) end
		end

	end

end