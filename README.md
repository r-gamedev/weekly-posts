# /r/Gamedev Weekly Posts

While running, automatically schedules posts found in `/threads`.

Selects a post to make from `posts.yaml` based off the modulo of `internal.yaml > post count`.

Gathers variables from `internal.yaml`, `posts.yaml > [selected] > variables`, and `conf.yaml`. With the priority in that order.

Generates a post title from `config.yaml > title`, replacing strings of the format `%{name}` with their variable counterpart.

Generates a post body from `format.yaml`, replacing strings of the format `%{name}` with their variable counterpart.

Posts to /r/gamedev when the chosen time has arrived, replacing the currently stickied weekly thread with the new one.

# Submitting posts

Modify the appropriate file and submit a pull request.

* `posts.yaml` for new random posts.
* `once.yaml` for new one-time-use posts. (not yet implemented)
* `format.yaml` to improve the post formatting.

# TODO

* One-time-use Timed posts `once.yaml`
  * By post immediately before date
  * By post immediately after date
  * By counter value
  * Move from `once.yaml` to `once-used.yaml`
