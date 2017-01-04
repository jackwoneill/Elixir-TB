defmodule NoFollow do

	def pop_followers_list(list, 0) do
		list
	end

	def pop_followers_list(list, nc) do
		fols = ExTwitter.follower_ids("INSERT HANDLE HERE", count: 200, cursor: nc)
		pop_followers_list(fols.items ++ list, fols.next_cursor)
	end

	##### BEGIN FINDING FOLLOWED USERS #####
	def pop_followed_list(list, 0) do
		list
	end

	def pop_followed_list(list, nc) do
		followed = ExTwitter.friend_ids("INSERT HANDLE HERE", count: 500, cursor: nc)
		pop_followed_list(followed.items ++ list, followed.next_cursor)
	end
	##### END FINDING FOLLOWED USERS ######

	def unfollow_users(list) do
		for user <- list, do: ExTwitter.unfollow(user)
	end

	def main do

		curr_user = ExTwitter.user("INSERT HANDLE HERE")

		to_unfollow = (pop_followed_list([], -1)) -- (pop_followers_list([], -1))
		pre_followed_count = curr_user.friends_count

		count_to_unfollow = length(to_unfollow)

		IO.puts(curr_user <> "Currently follows " <> Integer.to_string(pre_followed_count) <> " people.")
		IO.puts("Found " <> Integer.to_string(count_to_unfollow) <> " users to unfollow")

		split_to_unfollow = Enum.chunk(to_unfollow, 50, 50, [])
		
		for chunk <- split_to_unfollow  do
			spawn fn -> unfollow_users(chunk) end
		end

	end


end
