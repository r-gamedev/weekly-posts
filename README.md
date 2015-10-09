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
* `once.yaml` for new one-time-use posts. (not yet tested)
  * set `on-counter` to have the post show up when the counter is a certain value
  * set `before-date` to have the post show up within the week before the given date
  * set `after-date` to have the post show up within the week after the given date
  * set `keep` to have the post move to `posts.yaml` once used. Moved to `once-used.yaml` otherwise.
  * set `again` to have the post remain in `once.yaml` once used. Moved to `once-used.yaml` otherwise.
* `format.yaml` to improve the post formatting.

# TODO

* Testing
  * All.
  * The.
  * Things.
  * *(except posts.yaml)*
