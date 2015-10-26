# What is this?

A script and data for a bot that automatically generates and posts the daily/weekly threads to /r/gamedev, as well as stickies and flairs them as appropriate.

# How does it work?

It automatically schedules posts, one post type per `/threads` folder. It determines which thread to post by first looking at `/threads/[thread]/once.yaml` and seeing if a thread is scheduled. If no specific thread is scheduled, it grabs the top thread from the `threads/[thread]/posts.yaml` queue (and moves it to the bottom), combines that threads `variables` with the default `variables` from `/threads/[thread]/config.yaml` and passes them into `/threads/[thread]/format.md` and the title, and then posts it to reddit.

`format.md` and title variables are gathered from  `internal.yaml`, `posts.yaml > [selected] > variables`, and `conf.yaml`. With the priority in that order. The variables are used replace the `%{name}` counterparts in `format.yaml` and `conf.yaml`'s title.

# Contributing (post titles, bonus question, formatting, etc)

Modify the appropriate file (probably `posts.yaml`) and submit a pull request, or [message /r/gamedev](https://www.reddit.com/message/compose?to=%2Fr%2Fgamedev), or [fill out this form](https://docs.google.com/forms/d/1ce7sbdm-D_PJy3WC5FAbpZ6KprBKW4OcSL0hLxUvoQE/viewform).

(Optional) Run `validate.rb` before submitting to confirm all your changes are good to go.

## Base Text (`format.md`)

Edit `format.md` as though it were a reddit post, with the exception that %{variable} will be replaced with their counterpart from the merger of `internal.yaml`, `[selected post] > variables`, and `conf.yaml` (with priority in that order).

```yaml
# Standard Variables:

%{today}    - the current date YYYY-MM-DD
%{counter}  - the current post number
%{tagline}  - the (sub)title of the post
%{question} - question to appear at the end of the post
%{extra}    - bonus text to be included at the end of the post
```

## Regular posts (`posts.yaml`)

When no specific post is scheduled through `once.yaml`, the top post is selected from `posts.yaml` and moved to the bottom of `posts.yaml`.

```yaml
# Example posts.yaml entry
- variables:
    tagline: "Text to be included in the title"
    question: "Question to be included at the end" # optional
    bonus: "Text to be included after the end"  # optional
```

## Scheduled posts (`once.yaml`)

Specially scheduled posts. All entries should include one of `on_counter`, `after_date`, or `before_date`. Optionally they may include `keep: true` and `again: true` to move the entry to `posts.yaml` and keep the scheduling in `once.yaml`, respectively.

```yaml
# Posted when the %{counter} reaches 50 and discarded (moved to once-used.yaml)
- on_counter: 50
  variables:
    tagline: "Text to be included in the title"
    question: "Question to be included at the end" # optional
    bonus: "Text to be included after the end"  # optional

# Posted in the week after '04/01' and then kept (moved to the end of posts.yaml)
- after_date: '04/01'
  keep: true # this keeps the post (moves it to posts.yaml when we're done)
  variables:
    tagline: nothing nothing
    question: nothing nothing nothing
    bonus: |+ # Include multiple lines of text in this fashion
      line1
      line2
      
      line4

# Posted in the week before '04/01' and is used again (is kept in once.yaml and not moved)
- before_date: '04/01'
  again: true
  variables:
    tagline: April Fools
    question: Something something pranks.
    bonus: |+ # Include multiple lines of text in this fashion
      just literally paragraphs of text
      not even kidding
```

# TODO

* Testing
  * All.
  * The.
  * Things.
  * *(except posts.yaml)*
