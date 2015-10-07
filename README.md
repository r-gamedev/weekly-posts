# /r/Gamedev Weekly Posts

While running, automatically schedules posts found in `/threads` (excluding `example`, of course).

Selects the top post from `posts.yaml` and moves it to the bottom.

Gathers variables from `internal.yaml`, `posts.yaml > [selected] > variables`, and `conf.yaml`. With the priority in that order.

Generates a post title from `config.yaml > title`, replacing strings of the format `%{name}` with their variable counterpart.

Generates a post body from `format.yaml`, replacing strings of the format `%{name}` with their variable counterpart.

Posts to /r/gamedev when the chosen time has arrived, replacing the currently stickied weekly thread with the new one.

# Submitting posts

Modify the appropriate file and submit a pull request.

* `posts.yaml` for new regular posts.
* `once.yaml` for new one-time-use posts. (not yet implemented)
* `format.yaml` to improve the post formatting.

# TODO

* One-time-use Timed posts `once.yaml`
  * For posting immediately before date
  * For posting immediately after date
  * When the counter is at a set value
  * Move from `once.yaml` to `once-used.yaml` if not `keep: true`
  * Move from `once.yaml` to the end of `posts.yaml` if `keep: true`
